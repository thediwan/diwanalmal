import 'package:drift/drift.dart';

import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../features/goals/models/goal_draft.dart';
import 'lazarus_database_service.dart';

/// Persists financial goals to Lazarus SQLite.
class GoalService {
  GoalService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Loads a goal by id for the active user.
  Future<FinancialGoal?> getById(String goalId) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return null;

    return _db.financeDao.getGoalById(userId: userId, goalId: goalId);
  }

  /// Saves an accepted goal draft for the active user.
  Future<void> createFromDraft(GoalDraft draft) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal creation');
    }

    final now = DateTime.now();
    await _db.financeDao.insertGoal(
      GoalsCompanion.insert(
        id: UuidHelper.generate(),
        userId: userId,
        title: draft.title,
        targetAmount: draft.targetAmount,
        savedAmount: Value(draft.savedAmount),
        currencyId: draft.currencyId,
        icon: Value(draft.iconStyle),
        targetDate: Value(draft.targetDate),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Updates an existing goal from edited form data.
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
    await _db.financeDao.updateGoal(
      existing.copyWith(
        title: draft.title,
        targetAmount: draft.targetAmount,
        savedAmount: draft.savedAmount,
        currencyId: draft.currencyId,
        icon: Value(draft.iconStyle),
        targetDate: Value(draft.targetDate),
        updatedAt: now,
      ),
    );
  }

  /// Deletes a goal permanently.
  Future<void> delete(String goalId) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for goal deletion');
    }

    final deleted = await _db.financeDao.deleteGoal(
      userId: userId,
      goalId: goalId,
    );
    if (deleted == 0) {
      throw StateError('Goal not found');
    }
  }
}
