import 'package:drift/drift.dart';

import '../core/constants/goal_icon_styles.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../features/goals/models/goal_draft.dart';
import '../models/currency.dart';
import 'lazarus_database_service.dart';
import 'transfer_service.dart';

/// Persists financial goals and manages linked goal wallets.
class GoalService {
  GoalService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Loads a goal by id for the active user and refreshes saved amount cache.
  Future<FinancialGoal?> getById(String goalId) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return null;

    final goal = await _db.financeDao.getGoalById(
      userId: userId,
      goalId: goalId,
    );
    if (goal == null) return null;

    if (goal.walletId != null) {
      await _db.financeDao.syncGoalSavedAmount(goal);
      return _db.financeDao.getGoalById(userId: userId, goalId: goalId);
    }
    return goal;
  }

  /// Saves an accepted goal draft: creates wallet, optional opening transfer.
  Future<void> createFromDraft(GoalDraft draft) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal creation');
    }

    if (draft.savedAmount > 0 && draft.sourceWalletId == null) {
      throw StateError('source_wallet_required');
    }

    final goalCurrency = await _loadCurrency(draft.currencyId);
    if (goalCurrency == null) {
      throw StateError('currency_not_found');
    }

    final now = DateTime.now();
    final goalId = UuidHelper.generate();
    final walletId = UuidHelper.generate();
    final legacyIcon = GoalIconStyles.legacyEmoji(draft.iconStyle);

    await _db.transaction(() async {
      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: walletId,
              userId: userId,
              name: draft.title,
              icon: Value(legacyIcon),
              iconStyle: Value(draft.iconStyle),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.into(_db.walletCurrencyAccounts).insert(
            WalletCurrencyAccountsCompanion.insert(
              id: UuidHelper.generate(),
              walletId: walletId,
              currencyId: draft.currencyId,
              openingBalance: const Value(0),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.financeDao.insertGoal(
        GoalsCompanion.insert(
          id: goalId,
          userId: userId,
          walletId: Value(walletId),
          title: draft.title,
          targetAmount: draft.targetAmount,
          savedAmount: const Value(0),
          currencyId: draft.currencyId,
          icon: Value(draft.iconStyle),
          targetDate: Value(draft.targetDate),
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (draft.savedAmount > 0) {
        await _transferBetweenWallets(
          fromWalletId: draft.sourceWalletId!,
          toWalletId: walletId,
          amount: draft.savedAmount,
          goalCurrency: goalCurrency,
          transactionDate: now,
        );
      }

      final goal = await _db.financeDao.getGoalById(
        userId: userId,
        goalId: goalId,
      );
      if (goal != null) {
        await _db.financeDao.syncGoalSavedAmount(goal);
      }
    });
  }

  /// Updates goal metadata (not saved amount — that comes from wallet balance).
  Future<void> update({
    required String id,
    required GoalDraft draft,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal update');
    }

    final existing = await _db.financeDao.getGoalById(
      userId: userId,
      goalId: id,
    );
    if (existing == null) {
      throw StateError('Goal not found');
    }

    final now = DateTime.now();
    await _db.transaction(() async {
      await _db.financeDao.updateGoal(
        existing.copyWith(
          title: draft.title,
          targetAmount: draft.targetAmount,
          currencyId: draft.currencyId,
          icon: Value(draft.iconStyle),
          targetDate: Value(draft.targetDate),
          updatedAt: now,
        ),
      );

      if (existing.walletId != null) {
        final legacyIcon = GoalIconStyles.legacyEmoji(draft.iconStyle);
        await (_db.update(_db.wallets)
              ..where((w) => w.id.equals(existing.walletId!)))
            .write(
          WalletsCompanion(
            name: Value(draft.title),
            icon: Value(legacyIcon),
            iconStyle: Value(draft.iconStyle),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  /// Deletes a goal when its wallet has no remaining balance.
  Future<void> delete(String goalId) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal deletion');
    }

    final goal = await _db.financeDao.getGoalById(
      userId: userId,
      goalId: goalId,
    );
    if (goal == null) {
      throw StateError('Goal not found');
    }

    if (goal.walletId != null) {
      final balance = await _db.financeDao.computeAccountBalance(
        walletId: goal.walletId!,
        currencyId: goal.currencyId,
      );
      if (balance > 0.000001) {
        throw StateError('goal_wallet_has_balance');
      }
    }

    await _db.transaction(() async {
      if (goal.walletId != null) {
        final walletId = goal.walletId!;
        final now = DateTime.now();
        await (_db.update(_db.wallets)..where((w) => w.id.equals(walletId)))
            .write(
          WalletsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        await (_db.update(_db.walletCurrencyAccounts)
              ..where((a) => a.walletId.equals(walletId)))
            .write(
          WalletCurrencyAccountsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      final deleted = await _db.financeDao.deleteGoal(
        userId: userId,
        goalId: goalId,
      );
      if (deleted == 0) {
        throw StateError('Goal not found');
      }
    });
  }

  /// Transfers [amount] from [sourceWalletId] into the goal wallet.
  Future<void> deposit({
    required String goalId,
    required String sourceWalletId,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal deposit');
    }

    final goal = await _db.financeDao.getGoalById(
      userId: userId,
      goalId: goalId,
    );
    if (goal == null) {
      throw StateError('Goal not found');
    }
    final goalWalletId = goal.walletId;
    if (goalWalletId == null) {
      throw StateError('goal_wallet_missing');
    }

    final goalCurrency = await _loadCurrency(goal.currencyId);
    if (goalCurrency == null) {
      throw StateError('currency_not_found');
    }

    await _db.transaction(() async {
      await _transferBetweenWallets(
        fromWalletId: sourceWalletId,
        toWalletId: goalWalletId,
        amount: amount,
        goalCurrency: goalCurrency,
        transactionDate: date,
        notes: notes,
      );
      await _db.financeDao.syncGoalSavedAmount(goal);
    });
  }

  /// Transfers [amount] from the goal wallet to [destinationWalletId].
  Future<void> withdraw({
    required String goalId,
    required String destinationWalletId,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal withdrawal');
    }

    final goal = await _db.financeDao.getGoalById(
      userId: userId,
      goalId: goalId,
    );
    if (goal == null) {
      throw StateError('Goal not found');
    }
    final goalWalletId = goal.walletId;
    if (goalWalletId == null) {
      throw StateError('goal_wallet_missing');
    }

    final goalCurrency = await _loadCurrency(goal.currencyId);
    if (goalCurrency == null) {
      throw StateError('currency_not_found');
    }

    final goalBalance = await _db.financeDao.computeAccountBalance(
      walletId: goalWalletId,
      currencyId: goal.currencyId,
    );
    if (goalBalance < amount - 0.000001) {
      throw StateError('insufficient_goal_balance');
    }

    await _db.transaction(() async {
      await _transferBetweenWallets(
        fromWalletId: goalWalletId,
        toWalletId: destinationWalletId,
        amount: amount,
        goalCurrency: goalCurrency,
        transactionDate: date,
        notes: notes,
      );
      await _db.financeDao.syncGoalSavedAmount(goal);
    });
  }

  /// Net transfers into the goal wallet during the current calendar month.
  Future<double> netContributionsThisMonth(FinancialGoal goal) async {
    final walletId = goal.walletId;
    if (walletId == null) return 0;

    final now = DateTime.now();
    final dao = _db.financeDao;
    final deposits = await dao.sumTransfersToWalletInMonth(
      walletId: walletId,
      currencyId: goal.currencyId,
      year: now.year,
      month: now.month,
    );
    final withdrawals = await dao.sumTransfersFromWalletInMonth(
      walletId: walletId,
      currencyId: goal.currencyId,
      year: now.year,
      month: now.month,
    );
    return deposits - withdrawals;
  }

  Future<Currency?> _loadCurrency(String currencyId) async {
    final row = await (_db.select(_db.currencies)
          ..where((c) => c.id.equals(currencyId)))
        .getSingleOrNull();
    return row == null ? null : LazarusDatabaseService.toAppCurrency(row);
  }

  Future<void> _transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required Currency goalCurrency,
    required DateTime transactionDate,
    String? notes,
  }) async {
    final sourceAccount = await (_db.select(_db.walletCurrencyAccounts)
          ..where((a) => a.walletId.equals(fromWalletId))
          ..where((a) => a.currencyId.equals(goalCurrency.id))
          ..where((a) => a.deletedAt.isNull()))
        .getSingleOrNull();

    if (sourceAccount == null) {
      throw StateError('source_wallet_currency_mismatch');
    }

    final sourceBalance = await _db.financeDao.computeAccountBalance(
      walletId: fromWalletId,
      currencyId: goalCurrency.id,
    );
    if (sourceBalance < amount - 0.000001) {
      throw StateError('insufficient_wallet_balance');
    }

    await TransferService(_lazarus).createCurrencyTransfer(
      CreateCurrencyTransferInput(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        sourceCurrency: goalCurrency,
        targetCurrency: goalCurrency,
        sourceAmount: amount,
        notes: notes,
        transactionDate: transactionDate,
      ),
    );
  }
}
