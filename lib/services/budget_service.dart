import 'package:drift/drift.dart';

import '../core/constants/database_constants.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/daos/finance_dao.dart';
import '../database/lazarus_database.dart';
import 'category_service.dart';
import 'lazarus_database_service.dart';

/// Monthly category budget CRUD and validation.
class BudgetService {
  BudgetService(this._lazarus, this._categoryService);

  final LazarusDatabaseService _lazarus;
  final CategoryService _categoryService;

  FinanceDao get _dao => _lazarus.database.financeDao;

  /// Budget rows with actual spend for a calendar month.
  Future<List<BudgetWithActual>> getBudgetsWithActuals({
    required int year,
    required int month,
  }) async {
    final userId = await _requireUserId();
    return _dao.getBudgetsWithActuals(
      userId: userId,
      year: year,
      month: month,
    );
  }

  /// Loads one budget for editing.
  Future<Budget?> getById(String budgetId) async {
    final userId = await _requireUserId();
    return _dao.getBudgetById(userId: userId, budgetId: budgetId);
  }

  /// Creates a budget for an expense category in a calendar month.
  Future<void> create({
    required String categoryId,
    required int year,
    required int month,
    required double amount,
    required String currencyId,
  }) async {
    final userId = await _requireUserId();
    await _validateCategory(categoryId);
    if (amount <= 0) throw ArgumentError('budget_amount_invalid');

    final existing = await _dao.getBudgetForCategoryMonth(
      userId: userId,
      categoryId: categoryId,
      year: year,
      month: month,
    );
    if (existing != null) throw StateError('budget_category_exists');

    final now = DateTime.now();
    await _dao.upsertBudget(
      BudgetsCompanion.insert(
        id: UuidHelper.generate(),
        userId: userId,
        categoryId: categoryId,
        month: month,
        year: year,
        amount: amount,
        currencyId: currencyId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Updates budget amount and optional category/currency.
  Future<void> update({
    required String id,
    required String categoryId,
    required int year,
    required int month,
    required double amount,
    required String currencyId,
  }) async {
    final userId = await _requireUserId();
    await _validateCategory(categoryId);
    if (amount <= 0) throw ArgumentError('budget_amount_invalid');

    final existing = await _dao.getBudgetById(userId: userId, budgetId: id);
    if (existing == null) throw StateError('budget_not_found');

    final duplicate = await _dao.getBudgetForCategoryMonth(
      userId: userId,
      categoryId: categoryId,
      year: year,
      month: month,
    );
    if (duplicate != null && duplicate.id != id) {
      throw StateError('budget_category_exists');
    }

    await _dao.upsertBudget(
      BudgetsCompanion(
        id: Value(id),
        userId: Value(userId),
        categoryId: Value(categoryId),
        month: Value(month),
        year: Value(year),
        amount: Value(amount),
        currencyId: Value(currencyId),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a budget row.
  Future<void> delete(String budgetId) async {
    final userId = await _requireUserId();
    await _dao.deleteBudget(userId: userId, budgetId: budgetId);
  }

  /// Copies budgets from the previous calendar month.
  Future<int> copyFromPreviousMonth({
    required int year,
    required int month,
  }) async {
    final userId = await _requireUserId();
    return _dao.copyBudgetsFromPreviousMonth(
      userId: userId,
      year: year,
      month: month,
    );
  }

  Future<void> _validateCategory(String categoryId) async {
    final category = await _categoryService.getById(categoryId);
    if (category == null) throw StateError('category_not_found');
    if (category.type != DatabaseConstants.categoryExpense) {
      throw StateError('budget_expense_category_only');
    }
  }

  Future<String> _requireUserId() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) throw StateError('no_active_user');
    return userId;
  }
}
