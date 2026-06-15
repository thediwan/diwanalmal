import 'package:drift/drift.dart';

import '../core/constants/database_constants.dart';
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

/// Persists income and expense transactions.
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
        walletId: input.walletId,
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

  /// Validates transaction type string.
  static bool isIncome(String type) => type == DatabaseConstants.txIncome;

  static bool isExpense(String type) => type == DatabaseConstants.txExpense;
}
