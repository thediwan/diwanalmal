import 'package:drift/drift.dart';

import '../core/constants/transaction_policy.dart';
import '../core/helpers/currency_formatter.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/currency.dart';
import 'lazarus_database_service.dart';

/// Input for creating a cross-currency wallet transfer.
class CreateCurrencyTransferInput {
  const CreateCurrencyTransferInput({
    required this.fromWalletId,
    required this.toWalletId,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sourceAmount,
    this.crossExchangeRate,
    this.notes,
    required this.transactionDate,
  });

  final String fromWalletId;
  final String toWalletId;
  final Currency sourceCurrency;
  final Currency targetCurrency;
  final double sourceAmount;
  /// Target units received per one source unit (overrides currency table rates).
  final double? crossExchangeRate;
  final String? notes;
  final DateTime transactionDate;
}

/// Input for updating a cross-currency transfer.
class UpdateCurrencyTransferInput {
  const UpdateCurrencyTransferInput({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sourceAmount,
    this.crossExchangeRate,
    this.notes,
    required this.transactionDate,
  });

  final String id;
  final String fromWalletId;
  final String toWalletId;
  final Currency sourceCurrency;
  final Currency targetCurrency;
  final double sourceAmount;
  /// Target units received per one source unit (overrides currency table rates).
  final double? crossExchangeRate;
  final String? notes;
  final DateTime transactionDate;
}

/// Persists and mutates cross-currency wallet transfers.
class TransferService {
  TransferService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Converts [sourceAmount] from [source] to [target] using base rates.
  static double convertedAmount({
    required double sourceAmount,
    required Currency source,
    required Currency target,
  }) {
    return resolveTargetAmount(
      sourceAmount: sourceAmount,
      source: source,
      target: target,
    );
  }

  /// Default cross rate: 1 [source] = X [target].
  static double defaultCrossRate({
    required Currency source,
    required Currency target,
  }) {
    return resolveTargetAmount(
      sourceAmount: 1,
      source: source,
      target: target,
    );
  }

  /// Resolves target amount using an optional manual cross rate.
  static double resolveTargetAmount({
    required double sourceAmount,
    required Currency source,
    required Currency target,
    double? crossExchangeRate,
  }) {
    if (crossExchangeRate != null && crossExchangeRate > 0) {
      return sourceAmount * crossExchangeRate;
    }
    if (source.id == target.id) return sourceAmount;
    final base = CurrencyFormatter.toBaseAmount(sourceAmount, source.rateToBase);
    if (target.rateToBase == 0) return 0;
    return base / target.rateToBase;
  }

  /// Saves a cross-currency transfer for the active user.
  Future<void> createCurrencyTransfer(CreateCurrencyTransferInput input) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for transfer creation');
    }

    if (input.sourceAmount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    if (input.sourceCurrency.id == input.targetCurrency.id &&
        input.fromWalletId == input.toWalletId) {
      throw ArgumentError('Source and target must differ');
    }

    final targetAmount = resolveTargetAmount(
      sourceAmount: input.sourceAmount,
      source: input.sourceCurrency,
      target: input.targetCurrency,
      crossExchangeRate: input.crossExchangeRate,
    );
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.sourceAmount,
      input.sourceCurrency.rateToBase,
    );
    final now = DateTime.now();

    await _db.financeDao.insertTransfer(
      TransfersCompanion.insert(
        id: UuidHelper.generate(),
        userId: userId,
        fromWalletId: input.fromWalletId,
        toWalletId: input.toWalletId,
        amount: input.sourceAmount,
        currencyId: input.sourceCurrency.id,
        exchangeRate: input.sourceCurrency.rateToBase,
        baseAmount: baseAmount,
        toCurrencyId: Value(input.targetCurrency.id),
        toAmount: Value(targetAmount),
        toExchangeRate: Value(input.targetCurrency.rateToBase),
        notes: Value(input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim()),
        transactionDate: input.transactionDate,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Updates a transfer when still within the edit window.
  Future<void> updateCurrencyTransfer({
    required UpdateCurrencyTransferInput input,
    required int editWindowDays,
  }) async {
    final existing = await _db.financeDao.getTransferById(input.id);
    if (existing == null) {
      throw StateError('Transfer not found');
    }

    if (!TransactionPolicy.canEdit(
      createdAt: existing.transfer.createdAt,
      editWindowDays: editWindowDays,
    )) {
      throw StateError('Transfer edit window expired');
    }

    if (input.sourceAmount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final targetAmount = resolveTargetAmount(
      sourceAmount: input.sourceAmount,
      source: input.sourceCurrency,
      target: input.targetCurrency,
      crossExchangeRate: input.crossExchangeRate,
    );
    final baseAmount = CurrencyFormatter.toBaseAmount(
      input.sourceAmount,
      input.sourceCurrency.rateToBase,
    );

    await _db.financeDao.updateTransferRecord(
      TransfersCompanion(
        id: Value(input.id),
        fromWalletId: Value(input.fromWalletId),
        toWalletId: Value(input.toWalletId),
        amount: Value(input.sourceAmount),
        currencyId: Value(input.sourceCurrency.id),
        exchangeRate: Value(input.sourceCurrency.rateToBase),
        baseAmount: Value(baseAmount),
        toCurrencyId: Value(input.targetCurrency.id),
        toAmount: Value(targetAmount),
        toExchangeRate: Value(input.targetCurrency.rateToBase),
        notes: Value(input.notes?.trim().isEmpty ?? true ? null : input.notes!.trim()),
        transactionDate: Value(input.transactionDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft-deletes a transfer when still within the delete window.
  Future<void> delete({
    required String id,
    required int deleteWindowHours,
  }) async {
    final existing = await _db.financeDao.getTransferById(id);
    if (existing == null) {
      throw StateError('Transfer not found');
    }

    if (!TransactionPolicy.canDelete(
      createdAt: existing.transfer.createdAt,
      deleteWindowHours: deleteWindowHours,
    )) {
      throw StateError('Transfer delete window expired');
    }

    final deleted = await _db.financeDao.softDeleteTransfer(id);
    if (!deleted) {
      throw StateError('Could not delete transfer');
    }
  }
}
