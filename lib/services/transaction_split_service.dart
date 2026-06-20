import 'package:drift/drift.dart';

import '../core/constants/database_constants.dart';
import '../core/constants/split_constants.dart';
import '../core/constants/transaction_policy.dart';
import '../core/helpers/currency_formatter.dart';
import '../core/helpers/split_calculator.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/daos/finance_dao.dart';
import '../database/lazarus_database.dart';
import '../models/currency.dart';
import '../models/transaction_category.dart';
import 'contact_service.dart';
import 'debt_service.dart';
import 'lazarus_database_service.dart';

/// Draft participant for creating or updating a split transaction.
class SplitParticipantDraft {
  const SplitParticipantDraft({
    this.contactId,
    this.contactName,
    this.percent,
    this.fixedAmount,
  });

  final String? contactId;
  final String? contactName;
  final double? percent;
  final double? fixedAmount;

  bool get hasIdentity =>
      (contactId != null && contactId!.isNotEmpty) ||
      (contactName != null && contactName!.trim().isNotEmpty);
}

/// Input for creating an income/expense with optional split sharing.
class CreateSplitTransactionInput {
  const CreateSplitTransactionInput({
    required this.walletId,
    required this.category,
    required this.type,
    required this.amount,
    required this.currency,
    this.notes,
    required this.transactionDate,
    this.splitEnabled = false,
    this.splitMode = SplitConstants.modeEqual,
    this.includeSelfInEqualSplit = true,
    this.fixedAmountPerPerson,
    this.participants = const [],
  });

  final String walletId;
  final TransactionCategory category;
  final String type;
  final double amount;
  final Currency currency;
  final String? notes;
  final DateTime transactionDate;
  final bool splitEnabled;
  final String splitMode;
  final bool includeSelfInEqualSplit;
  final double? fixedAmountPerPerson;
  final List<SplitParticipantDraft> participants;
}

/// Input for updating a split parent transaction.
class UpdateSplitTransactionInput {
  const UpdateSplitTransactionInput({
    required this.transactionId,
    required this.walletId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.currency,
    this.notes,
    required this.transactionDate,
    this.splitEnabled = false,
    this.splitMode = SplitConstants.modeEqual,
    this.includeSelfInEqualSplit = true,
    this.fixedAmountPerPerson,
    this.participants = const [],
  });

  final String transactionId;
  final String walletId;
  final String categoryId;
  final String type;
  final double amount;
  final Currency currency;
  final String? notes;
  final DateTime transactionDate;
  final bool splitEnabled;
  final String splitMode;
  final bool includeSelfInEqualSplit;
  final double? fixedAmountPerPerson;
  final List<SplitParticipantDraft> participants;
}

/// Creates and maintains shared income/expense transactions with linked debts.
class TransactionSplitService {
  TransactionSplitService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  ContactService get _contacts => ContactService(_lazarus);

  DebtService get _debts => DebtService(_lazarus);

  /// Loads split detail for a parent transaction.
  Future<TransactionSplitDetail?> getDetailByTransactionId(
    String transactionId,
  ) {
    return _db.financeDao.getSplitDetailByTransactionId(transactionId);
  }

  /// Creates a parent transaction and optional split debts atomically.
  Future<String> create(CreateSplitTransactionInput input) async {
    if (!input.splitEnabled || input.participants.isEmpty) {
      return _createPlainTransaction(input);
    }

    return _createWithSplit(input);
  }

  /// Updates a transaction and rebuilds its split when allowed.
  Future<void> update({
    required UpdateSplitTransactionInput input,
    required int editWindowDays,
  }) async {
    final existing = await _db.financeDao.getTransactionById(input.transactionId);
    if (existing == null) {
      throw StateError('Transaction not found');
    }

    if (!TransactionPolicy.canEdit(
      createdAt: existing.transaction.createdAt,
      editWindowDays: editWindowDays,
    )) {
      throw StateError('Transaction edit window expired');
    }

    final hadSplit =
        await _db.financeDao.getSplitByTransactionId(input.transactionId) != null;

    if (hadSplit) {
      await _assertSplitDebtsEditable(input.transactionId);
    }

    if (!input.splitEnabled || input.participants.isEmpty) {
      await _updatePlainTransaction(input);
      if (hadSplit) {
        await _removeSplitArtifacts(input.transactionId);
      }
      return;
    }

    await _updateWithSplit(input, hadSplit: hadSplit);
  }

  Future<String> _createPlainTransaction(CreateSplitTransactionInput input) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for transaction creation');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final now = DateTime.now();
    final txId = UuidHelper.generate();
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();

    await _db.financeDao.insertTransaction(
      TransactionsCompanion.insert(
        id: txId,
        userId: userId,
        walletId: Value(input.walletId),
        categoryId: Value(input.category.id),
        type: input.type,
        title: input.category.name,
        amount: input.amount,
        currencyId: input.currency.id,
        exchangeRate: input.currency.rateToBase,
        baseAmount: baseAmount,
        notes: Value(trimmedNotes),
        transactionDate: input.transactionDate,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return txId;
  }

  Future<String> _createWithSplit(CreateSplitTransactionInput input) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for split transaction');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    if (!SplitConstants.isValidMode(input.splitMode)) {
      throw ArgumentError('Invalid split mode');
    }

    final resolvedParticipants = await _resolveParticipants(input.participants);
    final calculation = SplitCalculator.calculate(
      totalAmount: input.amount,
      splitMode: input.splitMode,
      participants: resolvedParticipants
          .map(
            (p) => SplitParticipantInput(
              contactId: p.contactId,
              percent: p.percent,
              fixedAmount: p.fixedAmount,
            ),
          )
          .toList(),
      includeSelfInEqualSplit: input.includeSelfInEqualSplit,
      fixedAmountPerPerson: input.fixedAmountPerPerson,
    );

    final debtTxType = input.type == DatabaseConstants.txExpense
        ? DatabaseConstants.txDebtor
        : DatabaseConstants.txCreditor;

    final now = DateTime.now();
    final txId = UuidHelper.generate();
    final splitId = UuidHelper.generate();
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();

    await _db.transaction(() async {
      await _db.financeDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          userId: userId,
          walletId: Value(input.walletId),
          categoryId: Value(input.category.id),
          type: input.type,
          title: input.category.name,
          amount: input.amount,
          currencyId: input.currency.id,
          exchangeRate: input.currency.rateToBase,
          baseAmount: baseAmount,
          notes: Value(trimmedNotes),
          transactionDate: input.transactionDate,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await _db.financeDao.insertTransactionSplit(
        TransactionSplitsCompanion.insert(
          id: splitId,
          userId: userId,
          transactionId: txId,
          splitMode: input.splitMode,
          includeSelfInEqualSplit: Value(input.includeSelfInEqualSplit),
          fixedAmountPerPerson: Value(input.fixedAmountPerPerson),
          userShareAmount: calculation.userShareAmount,
          totalAmount: input.amount,
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (var i = 0; i < calculation.participantShares.length; i++) {
        final share = calculation.participantShares[i];
        if (share.shareAmount <= 0) continue;

        final draft = resolvedParticipants[i];
        final contact = await _contacts.getById(share.contactId);
        if (contact == null) continue;

        final participantId = UuidHelper.generate();
        await _db.financeDao.insertTransactionSplitParticipant(
          TransactionSplitParticipantsCompanion.insert(
            id: participantId,
            splitId: splitId,
            contactId: share.contactId,
            shareAmount: share.shareAmount,
            sharePercent: Value(share.sharePercent ?? draft.percent),
            sortOrder: Value(i),
          ),
        );

        final debtResult = await _debts.createLinked(
          CreateDebtEntryInput(
            type: debtTxType,
            walletId: input.walletId,
            personName: contact.name,
            contactId: contact.id,
            amount: share.shareAmount,
            currency: input.currency,
            parentTransactionId: txId,
            notes: trimmedNotes,
            transactionDate: input.transactionDate,
          ),
        );

        await _db.financeDao.updateSplitParticipantLinks(
          participantId: participantId,
          debtId: debtResult.debtId,
          debtTransactionId: debtResult.transactionId,
        );
      }
    });

    return txId;
  }

  Future<void> _updatePlainTransaction(UpdateSplitTransactionInput input) async {
    final categoryName =
        await _db.financeDao.getCategoryName(input.categoryId);
    final existing = await _db.financeDao.getTransactionById(input.transactionId);
    if (existing == null) {
      throw StateError('Transaction not found');
    }

    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();

    await _db.financeDao.updateTransactionRecord(
      TransactionsCompanion(
        id: Value(input.transactionId),
        walletId: Value(input.walletId),
        categoryId: Value(input.categoryId),
        title: Value(categoryName ?? existing.transaction.title),
        amount: Value(input.amount),
        currencyId: Value(input.currency.id),
        exchangeRate: Value(input.currency.rateToBase),
        baseAmount: Value(baseAmount),
        notes: Value(trimmedNotes),
        transactionDate: Value(input.transactionDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _updateWithSplit(
    UpdateSplitTransactionInput input, {
    required bool hadSplit,
  }) async {
    if (hadSplit) {
      await _removeSplitChildDebts(input.transactionId);
      await _db.financeDao.softDeleteSplitByTransactionId(input.transactionId);
    }

    final resolvedParticipants = await _resolveParticipants(input.participants);
    final calculation = SplitCalculator.calculate(
      totalAmount: input.amount,
      splitMode: input.splitMode,
      participants: resolvedParticipants
          .map(
            (p) => SplitParticipantInput(
              contactId: p.contactId,
              percent: p.percent,
              fixedAmount: p.fixedAmount,
            ),
          )
          .toList(),
      includeSelfInEqualSplit: input.includeSelfInEqualSplit,
      fixedAmountPerPerson: input.fixedAmountPerPerson,
    );

    final debtTxType = input.type == DatabaseConstants.txExpense
        ? DatabaseConstants.txDebtor
        : DatabaseConstants.txCreditor;

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for split transaction');
    }

    final now = DateTime.now();
    final splitId = UuidHelper.generate();
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();
    final categoryName =
        await _db.financeDao.getCategoryName(input.categoryId);

    await _db.transaction(() async {
      await _db.financeDao.updateTransactionRecord(
        TransactionsCompanion(
          id: Value(input.transactionId),
          walletId: Value(input.walletId),
          categoryId: Value(input.categoryId),
          title: Value(categoryName ?? ''),
          amount: Value(input.amount),
          currencyId: Value(input.currency.id),
          exchangeRate: Value(input.currency.rateToBase),
          baseAmount: Value(baseAmount),
          notes: Value(trimmedNotes),
          transactionDate: Value(input.transactionDate),
          updatedAt: Value(now),
        ),
      );

      await _db.financeDao.insertTransactionSplit(
        TransactionSplitsCompanion.insert(
          id: splitId,
          userId: userId,
          transactionId: input.transactionId,
          splitMode: input.splitMode,
          includeSelfInEqualSplit: Value(input.includeSelfInEqualSplit),
          fixedAmountPerPerson: Value(input.fixedAmountPerPerson),
          userShareAmount: calculation.userShareAmount,
          totalAmount: input.amount,
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (var i = 0; i < calculation.participantShares.length; i++) {
        final share = calculation.participantShares[i];
        if (share.shareAmount <= 0) continue;

        final contact = await _contacts.getById(share.contactId);
        if (contact == null) continue;

        final participantId = UuidHelper.generate();
        await _db.financeDao.insertTransactionSplitParticipant(
          TransactionSplitParticipantsCompanion.insert(
            id: participantId,
            splitId: splitId,
            contactId: share.contactId,
            shareAmount: share.shareAmount,
            sharePercent: Value(share.sharePercent),
            sortOrder: Value(i),
          ),
        );

        final debtResult = await _debts.createLinked(
          CreateDebtEntryInput(
            type: debtTxType,
            walletId: input.walletId,
            personName: contact.name,
            contactId: contact.id,
            amount: share.shareAmount,
            currency: input.currency,
            parentTransactionId: input.transactionId,
            notes: trimmedNotes,
            transactionDate: input.transactionDate,
          ),
        );

        await _db.financeDao.updateSplitParticipantLinks(
          participantId: participantId,
          debtId: debtResult.debtId,
          debtTransactionId: debtResult.transactionId,
        );
      }
    });
  }

  Future<void> _removeSplitArtifacts(String transactionId) async {
    await _removeSplitChildDebts(transactionId);
    await _db.financeDao.softDeleteSplitByTransactionId(transactionId);
  }

  Future<void> _removeSplitChildDebts(String parentTransactionId) async {
    final children =
        await _db.financeDao.getSplitChildTransactions(parentTransactionId);
    final now = DateTime.now();

    for (final child in children) {
      final debtId = child.debtId;
      if (debtId != null) {
        final paid = await _db.financeDao.sumDebtPaymentsAmount(debtId);
        if (paid > 0) {
          throw StateError('Cannot modify split with settled debts');
        }
      }

      await _db.financeDao.softDeleteTransaction(child.id);
      if (debtId != null) {
        await (_db.update(_db.debts)..where((d) => d.id.equals(debtId))).write(
          DebtsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  Future<void> _assertSplitDebtsEditable(String transactionId) async {
    final detail = await _db.financeDao.getSplitDetailByTransactionId(
      transactionId,
    );
    if (detail == null) return;

    for (final line in detail.participants) {
      final debtId = line.participant.debtId;
      if (debtId == null) continue;
      final paid = await _db.financeDao.sumDebtPaymentsAmount(debtId);
      if (paid > 0) {
        throw StateError('Cannot edit split with settled debts');
      }
    }
  }

  Future<List<_ResolvedParticipant>> _resolveParticipants(
    List<SplitParticipantDraft> drafts,
  ) async {
    final validDrafts = drafts.where((d) => d.hasIdentity).toList();
    if (validDrafts.isEmpty) {
      throw ArgumentError('At least one participant is required');
    }

    final resolved = <_ResolvedParticipant>[];
    for (final draft in validDrafts) {
      DbContact contact;
      if (draft.contactId != null && draft.contactId!.isNotEmpty) {
        final existing = await _contacts.getById(draft.contactId!);
        if (existing == null) {
          throw ArgumentError('Contact not found');
        }
        contact = existing;
      } else {
        contact = await _contacts.findOrCreateByName(draft.contactName!.trim());
      }

      resolved.add(
        _ResolvedParticipant(
          contactId: contact.id,
          percent: draft.percent,
          fixedAmount: draft.fixedAmount,
        ),
      );
    }

    return resolved;
  }
}

class _ResolvedParticipant {
  const _ResolvedParticipant({
    required this.contactId,
    this.percent,
    this.fixedAmount,
  });

  final String contactId;
  final double? percent;
  final double? fixedAmount;
}
