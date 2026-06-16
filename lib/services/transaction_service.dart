import 'package:drift/drift.dart';

import '../core/constants/database_constants.dart';
import '../core/constants/transaction_policy.dart';
import '../core/helpers/currency_formatter.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/currency.dart';
import '../models/transaction_category.dart';
import 'lazarus_database_service.dart';

/// Input for creating an income or expense transaction.
class CreateTransactionInput {
  const CreateTransactionInput({
    required this.walletId,
    required this.category,
    required this.type,
    required this.amount,
    required this.currency,
    this.notes,
    required this.transactionDate,
  });

  final String walletId;
  final TransactionCategory category;
  final String type;
  final double amount;
  final Currency currency;
  final String? notes;
  final DateTime transactionDate;
}

/// Input for updating an income or expense transaction.
class UpdateTransactionInput {
  const UpdateTransactionInput({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.currency,
    this.notes,
    required this.transactionDate,
  });

  final String id;
  final String walletId;
  final String categoryId;
  final double amount;
  final Currency currency;
  final String? notes;
  final DateTime transactionDate;
}

/// Persists and mutates income and expense transactions.
class TransactionService {
  TransactionService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Saves a new transaction for the active user.
  Future<void> create(CreateTransactionInput input) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for transaction creation');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final now = DateTime.now();
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );

    await _db.financeDao.insertTransaction(
      TransactionsCompanion.insert(
        id: UuidHelper.generate(),
        userId: userId,
        walletId: Value(input.walletId),
        categoryId: Value(input.category.id),
        type: input.type,
        title: input.category.name,
        amount: input.amount,
        currencyId: input.currency.id,
        exchangeRate: input.currency.rateToBase,
        baseAmount: baseAmount,
        notes: Value(input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim()),
        transactionDate: input.transactionDate,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Updates a transaction when still within the edit window.
  Future<void> update({
    required UpdateTransactionInput input,
    required int editWindowDays,
  }) async {
    final existing = await _db.financeDao.getTransactionById(input.id);
    if (existing == null) {
      throw StateError('Transaction not found');
    }

    if (!TransactionPolicy.canEdit(
      createdAt: existing.transaction.createdAt,
      editWindowDays: editWindowDays,
    )) {
      throw StateError('Transaction edit window expired');
    }

    if (input.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.amount,
      input.currency.rateToBase,
    );
    final categoryName =
        await _db.financeDao.getCategoryName(input.categoryId);

    await _db.financeDao.updateTransactionRecord(
      TransactionsCompanion(
        id: Value(input.id),
        walletId: Value(input.walletId),
        categoryId: Value(input.categoryId),
        title: Value(categoryName ?? existing.transaction.title),
        amount: Value(input.amount),
        currencyId: Value(input.currency.id),
        exchangeRate: Value(input.currency.rateToBase),
        baseAmount: Value(baseAmount),
        notes: Value(input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim()),
        transactionDate: Value(input.transactionDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft-deletes a transaction when still within the delete window.
  Future<void> delete({
    required String id,
    required int deleteWindowHours,
  }) async {
    final existing = await _db.financeDao.getTransactionById(id);
    if (existing == null) {
      throw StateError('Transaction not found');
    }

    if (!TransactionPolicy.canDelete(
      createdAt: existing.transaction.createdAt,
      deleteWindowHours: deleteWindowHours,
    )) {
      throw StateError('Transaction delete window expired');
    }

    final deleted = await _db.financeDao.softDeleteTransaction(id);
    if (!deleted) {
      throw StateError('Could not delete transaction');
    }
  }

  /// Validates transaction type string.
  static bool isIncome(String type) => type == DatabaseConstants.txIncome;

  static bool isExpense(String type) => type == DatabaseConstants.txExpense;
}
