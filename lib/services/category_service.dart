import 'package:drift/drift.dart';

import '../core/constants/database_constants.dart';
import '../core/helpers/category_localization.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../database/seed/system_category_service.dart';
import '../models/transaction_category.dart';
import 'lazarus_database_service.dart';

/// Loads and mutates transaction categories in Lazarus SQLite.
class CategoryService {
  CategoryService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Expense categories for the active user.
  Future<List<TransactionCategory>> getExpenseCategories() async {
    await _ensureSystemCategories();
    return _getByType(DatabaseConstants.categoryExpense);
  }

  /// Income categories for the active user.
  Future<List<TransactionCategory>> getIncomeCategories() async {
    await _ensureSystemCategories();
    return _getByType(DatabaseConstants.categoryIncome);
  }

  /// All non-deleted categories for filter sheets.
  Future<List<TransactionCategory>> getAllCategories() async {
    final expense = await getExpenseCategories();
    final income = await getIncomeCategories();
    return [...expense, ...income];
  }

  /// Loads one category by id for the active user.
  Future<TransactionCategory?> getById(String id) async {
    await _ensureSystemCategories();
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return null;

    final row = await _db.financeDao.getCategoryById(id);
    if (row == null || row.userId != userId) return null;
    return _mapRow(row);
  }

  /// Protected general income category for automatic income transactions.
  Future<TransactionCategory?> getSystemGeneralIncomeCategory() async {
    final categories = await getIncomeCategories();
    return categories
        .where(
          (c) => c.id == DatabaseConstants.systemGeneralIncomeCategoryId,
        )
        .firstOrNull;
  }

  /// Protected general expense category.
  Future<TransactionCategory?> getSystemGeneralExpenseCategory() async {
    final categories = await getExpenseCategories();
    return categories
        .where(
          (c) => c.id == DatabaseConstants.systemGeneralExpenseCategoryId,
        )
        .firstOrNull;
  }

  /// Creates a user-defined category.
  Future<TransactionCategory> create({
    required String name,
    required String type,
    required String iconKey,
    required String colorHex,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('no_active_user');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('category_name_required');
    }

    final now = DateTime.now();
    final id = UuidHelper.generate();

    await _db.financeDao.insertCategory(
      CategoriesCompanion.insert(
        id: id,
        userId: userId,
        name: trimmed,
        type: type,
        icon: Value(iconKey),
        color: Value(colorHex),
        isDefault: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return TransactionCategory(
      id: id,
      name: trimmed,
      type: type,
      iconKey: iconKey,
      colorHex: colorHex,
      isDefault: false,
    );
  }

  /// Updates a non-system category.
  Future<TransactionCategory> update({
    required String id,
    required String name,
    required String iconKey,
    required String colorHex,
  }) async {
    if (DatabaseConstants.isSystemCategoryId(id)) {
      throw StateError('category_system_protected');
    }

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('no_active_user');
    }

    final existing = await _db.financeDao.getCategoryById(id);
    if (existing == null || existing.userId != userId) {
      throw StateError('category_not_found');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('category_name_required');
    }

    final now = DateTime.now();
    final updated = await _db.financeDao.updateCategory(
      CategoriesCompanion(
        id: Value(id),
        name: Value(trimmed),
        icon: Value(iconKey),
        color: Value(colorHex),
        updatedAt: Value(now),
      ),
    );

    if (!updated) {
      throw StateError('category_not_found');
    }

    return TransactionCategory(
      id: id,
      name: trimmed,
      type: existing.type,
      iconKey: iconKey,
      colorHex: colorHex,
      isDefault: existing.isDefault,
    );
  }

  /// Soft-deletes a category when it has no linked transactions.
  Future<void> delete(String id) async {
    if (DatabaseConstants.isSystemCategoryId(id)) {
      throw StateError('category_system_protected');
    }

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('no_active_user');
    }

    final existing = await _db.financeDao.getCategoryById(id);
    if (existing == null || existing.userId != userId) {
      throw StateError('category_not_found');
    }

    final txCount = await _db.financeDao.countTransactionsForCategory(id);
    if (txCount > 0) {
      throw StateError('category_has_transactions');
    }

    final deleted = await _db.financeDao.softDeleteCategory(id, DateTime.now());
    if (!deleted) {
      throw StateError('category_not_found');
    }
  }

  /// Whether any non-deleted transaction uses this category.
  Future<bool> hasTransactions(String categoryId) async {
    final count = await _db.financeDao.countTransactionsForCategory(categoryId);
    return count > 0;
  }

  Future<void> _ensureSystemCategories() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return;
    await SystemCategoryService(_db).ensureForUser(userId);
  }

  Future<List<TransactionCategory>> _getByType(String type) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final rows = await _db.financeDao.getCategoriesByType(
      userId: userId,
      type: type,
    );

    final categories = rows.map(_mapRow).toList();
    return _sortSystemFirst(categories);
  }

  TransactionCategory _mapRow(Category row) {
    return TransactionCategory(
      id: row.id,
      name: row.name,
      type: row.type,
      iconKey: row.icon,
      colorHex: row.color,
      isDefault: row.isDefault,
    );
  }

  List<TransactionCategory> _sortSystemFirst(
    List<TransactionCategory> categories,
  ) {
    final sorted = List<TransactionCategory>.from(categories);
    sorted.sort((a, b) {
      if (a.isSystem && !b.isSystem) return -1;
      if (!a.isSystem && b.isSystem) return 1;
      return a.name.compareTo(b.name);
    });
    return sorted;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
