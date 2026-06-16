import 'package:drift/drift.dart';

import '../core/constants/database_constants.dart';
import '../core/constants/transaction_policy.dart';
import '../core/helpers/currency_formatter.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/daos/finance_dao.dart';
import '../database/lazarus_database.dart';
import '../models/currency.dart';
import 'lazarus_database_service.dart';

/// Input for creating a receivable (debtor) or payable (creditor) entry.
class CreateDebtEntryInput {
  const CreateDebtEntryInput({
    required this.type,
    required this.walletId,
    required this.personName,
    required this.amount,
    required this.currency,
    this.dueDate,
    this.notes,
    required this.transactionDate,
  });

  /// [DatabaseConstants.txDebtor] or [DatabaseConstants.txCreditor].
  final String type;
  final String walletId;
  final String personName;
  final double amount;
  final Currency currency;
  final DateTime? dueDate;
  final String? notes;
  final DateTime transactionDate;
}

/// Input for updating a debt ledger transaction.
class UpdateDebtEntryInput {
  const UpdateDebtEntryInput({
    required this.transactionId,
    required this.debtId,
    required this.type,
    required this.walletId,
    required this.personName,
    required this.amount,
    required this.currency,
    this.dueDate,
    this.notes,
    required this.transactionDate,
  });

  final String transactionId;
  final String debtId;
  final String type;
  final String walletId;
  final String personName;
  final double amount;
  final Currency currency;
  final DateTime? dueDate;
  final String? notes;
  final DateTime transactionDate;
}

/// Input for partial or full debt settlement (pay / receive).
class SettleDebtInput {
  const SettleDebtInput({
    required this.debtId,
    required this.amount,
    required this.currency,
    required this.settlementTitle,
    this.notes,
    required this.paymentDate,
  });

  final String debtId;
  final double amount;
  final Currency currency;
  final String settlementTitle;
  final String? notes;
  final DateTime paymentDate;
}

/// Persists receivable/payable entries in [Debts] + [Transactions].
class DebtService {
  DebtService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Maps transaction type to debt table type.
  static String debtTypeForTransaction(String txType) {
    return txType == DatabaseConstants.txDebtor
        ? DatabaseConstants.debtOwedToMe
        : DatabaseConstants.debtIOwe;
  }

  /// Settlement transaction type for wallet balance impact.
  static String settlementTransactionType(String debtType) {
    return debtType == DatabaseConstants.debtOwedToMe
        ? DatabaseConstants.txIncome
        : DatabaseConstants.txExpense;
  }

  /// Loads debt detail for a ledger transaction id.
  Future<DebtLedgerDetail?> getDetailByLedgerTransactionId(
    String transactionId,
  ) {
    return _db.financeDao.getDebtDetailByLedgerTransactionId(transactionId);
  }

  /// Creates linked debt + transaction rows (no wallet balance impact yet).
  Future<void> create(CreateDebtEntryInput input) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for debt entry');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final person = input.personName.trim();
    if (person.isEmpty) {
      throw ArgumentError('Person name is required');
    }

    if (input.walletId.trim().isEmpty) {
      throw ArgumentError('Wallet is required');
    }

    if (!DatabaseConstants.isDebtLedgerType(input.type)) {
      throw ArgumentError('Invalid debt transaction type');
    }

    final now = DateTime.now();
    final debtId = UuidHelper.generate();
    final txId = UuidHelper.generate();
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();

    await _db.transaction(() async {
      await _db.financeDao.insertDebt(
        DebtsCompanion.insert(
          id: debtId,
          userId: userId,
          walletId: input.walletId,
          personName: person,
          type: debtTypeForTransaction(input.type),
          amount: input.amount,
          currencyId: input.currency.id,
          exchangeRate: input.currency.rateToBase,
          baseAmount: baseAmount,
          dueDate: Value(input.dueDate),
          notes: Value(trimmedNotes),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await _db.financeDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          userId: userId,
          walletId: Value(input.walletId),
          debtId: Value(debtId),
          type: input.type,
          title: person,
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
    });
  }

  /// Updates debt + transaction when still within the edit window.
  Future<void> update({
    required UpdateDebtEntryInput input,
    required int editWindowDays,
  }) async {
    final existing = await _db.financeDao.getTransactionById(input.transactionId);
    if (existing == null) {
      throw StateError('Debt transaction not found');
    }

    if (!TransactionPolicy.canEdit(
      createdAt: existing.transaction.createdAt,
      editWindowDays: editWindowDays,
    )) {
      throw StateError('Edit window expired');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final person = input.personName.trim();
    if (person.isEmpty) {
      throw ArgumentError('Person name is required');
    }

    if (input.walletId.trim().isEmpty) {
      throw ArgumentError('Wallet is required');
    }

    final paid = await _db.financeDao.sumDebtPaymentsAmount(input.debtId);
    if (input.amount < paid) {
      throw ArgumentError('Amount cannot be less than already paid');
    }

    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.financeDao.updateDebtRecord(
        DebtsCompanion(
          id: Value(input.debtId),
          walletId: Value(input.walletId),
          personName: Value(person),
          type: Value(debtTypeForTransaction(input.type)),
          amount: Value(input.amount),
          currencyId: Value(input.currency.id),
          exchangeRate: Value(input.currency.rateToBase),
          baseAmount: Value(baseAmount),
          dueDate: Value(input.dueDate),
          notes: Value(trimmedNotes),
          updatedAt: Value(now),
        ),
      );

      await _db.financeDao.updateTransactionRecord(
        TransactionsCompanion(
          id: Value(input.transactionId),
          walletId: Value(input.walletId),
          type: Value(input.type),
          title: Value(person),
          amount: Value(input.amount),
          currencyId: Value(input.currency.id),
          exchangeRate: Value(input.currency.rateToBase),
          baseAmount: Value(baseAmount),
          notes: Value(trimmedNotes),
          transactionDate: Value(input.transactionDate),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// Records partial or full pay/receive against a debt and posts wallet movement.
  Future<void> settle(SettleDebtInput input) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for debt settlement');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final debt = await _db.financeDao.getDebtById(input.debtId);
    if (debt == null) {
      throw StateError('Debt not found');
    }

    if (debt.isPaid) {
      throw StateError('Debt is already fully settled');
    }

    if (input.currency.id != debt.currencyId) {
      throw ArgumentError('Settlement currency must match the debt currency');
    }

    final paidSoFar = await _db.financeDao.sumDebtPaymentsAmount(input.debtId);
    final remaining = debt.amount - paidSoFar;
    if (input.amount > remaining + 0.000001) {
      throw ArgumentError('Amount exceeds remaining balance');
    }

    final now = DateTime.now();
    final paymentId = UuidHelper.generate();
    final txId = UuidHelper.generate();
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final trimmedNotes =
        input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim();
    final settlementType = settlementTransactionType(debt.type);

    await _db.transaction(() async {
      await _db.financeDao.insertDebtPayment(
        DebtPaymentsCompanion.insert(
          id: paymentId,
          debtId: input.debtId,
          amount: input.amount,
          currencyId: input.currency.id,
          exchangeRate: input.currency.rateToBase,
          baseAmount: baseAmount,
          paymentDate: input.paymentDate,
          notes: Value(trimmedNotes),
          createdAt: now,
        ),
      );

      await _db.financeDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          userId: userId,
          walletId: Value(debt.walletId),
          debtId: Value(input.debtId),
          type: settlementType,
          title: input.settlementTitle,
          amount: input.amount,
          currencyId: input.currency.id,
          exchangeRate: input.currency.rateToBase,
          baseAmount: baseAmount,
          notes: Value(trimmedNotes),
          transactionDate: input.paymentDate,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final newPaid = paidSoFar + input.amount;
      final fullyPaid = newPaid >= debt.amount - 0.000001;

      await _db.financeDao.updateDebtRecord(
        DebtsCompanion(
          id: Value(input.debtId),
          isPaid: Value(fullyPaid),
          paidAt: Value(fullyPaid ? input.paymentDate : debt.paidAt),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// Soft-deletes linked transaction and debt when within delete window.
  Future<void> delete({
    required String transactionId,
    required int deleteWindowHours,
  }) async {
    final existing = await _db.financeDao.getTransactionById(transactionId);
    if (existing == null) {
      throw StateError('Debt transaction not found');
    }

    if (!TransactionPolicy.canDelete(
      createdAt: existing.transaction.createdAt,
      deleteWindowHours: deleteWindowHours,
    )) {
      throw StateError('Delete window expired');
    }

    final debtId = existing.transaction.debtId;
    if (debtId != null) {
      final paid = await _db.financeDao.sumDebtPaymentsAmount(debtId);
      if (paid > 0) {
        throw StateError('Cannot delete debt with payments');
      }
    }

    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.financeDao.softDeleteTransaction(transactionId);
      if (debtId != null) {
        await (_db.update(_db.debts)..where((d) => d.id.equals(debtId))).write(
          DebtsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
