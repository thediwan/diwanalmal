import 'package:drift/drift.dart';

import '../../core/constants/database_constants.dart';
import '../lazarus_database.dart';

/// Seeds default income/expense categories on first app setup.
class CategorySeedService {
  CategorySeedService(this._db);

  final LazarusDatabase _db;

  /// Inserts default categories; existing rows with the same id are kept.
  Future<void> ensureDefaultCategories(String userId) async {
    final now = DateTime.now();
    final rows = _defaultRows(userId: userId, now: now);

    await _db.batch((batch) {
      for (final row in rows) {
        batch.insert(_db.categories, row, mode: InsertMode.insertOrIgnore);
      }
    });
  }

  List<CategoriesCompanion> _defaultRows({
    required String userId,
    required DateTime now,
  }) {
    return [
      _row(
        id: 'cat-shopping',
        userId: userId,
        name: 'تسوق',
        type: DatabaseConstants.categoryExpense,
        icon: 'shopping',
        color: '#2563EB',
        now: now,
      ),
      _row(
        id: 'cat-food',
        userId: userId,
        name: 'طعام',
        type: DatabaseConstants.categoryExpense,
        icon: 'food',
        color: '#EA580C',
        now: now,
      ),
      _row(
        id: 'cat-transport',
        userId: userId,
        name: 'مواصلات',
        type: DatabaseConstants.categoryExpense,
        icon: 'transport',
        color: '#7C3AED',
        now: now,
      ),
      _row(
        id: 'cat-home',
        userId: userId,
        name: 'منزل',
        type: DatabaseConstants.categoryExpense,
        icon: 'home',
        color: '#0891B2',
        now: now,
      ),
      _row(
        id: 'cat-health',
        userId: userId,
        name: 'صحة',
        type: DatabaseConstants.categoryExpense,
        icon: 'health',
        color: '#DC2626',
        now: now,
      ),
      _row(
        id: 'cat-sport',
        userId: userId,
        name: 'رياضة',
        type: DatabaseConstants.categoryExpense,
        icon: 'sport',
        color: '#16A34A',
        now: now,
      ),
      _row(
        id: 'cat-bills',
        userId: userId,
        name: 'فواتير',
        type: DatabaseConstants.categoryExpense,
        icon: 'bills',
        color: '#CA8A04',
        now: now,
      ),
      _row(
        id: 'cat-salary',
        userId: userId,
        name: 'راتب',
        type: DatabaseConstants.categoryIncome,
        icon: 'salary',
        color: '#16A34A',
        now: now,
      ),
      _row(
        id: 'cat-freelance',
        userId: userId,
        name: 'عمل حر',
        type: DatabaseConstants.categoryIncome,
        icon: 'freelance',
        color: '#1A56BE',
        now: now,
      ),
      _row(
        id: 'cat-investment',
        userId: userId,
        name: 'استثمار',
        type: DatabaseConstants.categoryIncome,
        icon: 'investment',
        color: '#059669',
        now: now,
      ),
    ];
  }

  CategoriesCompanion _row({
    required String id,
    required String userId,
    required String name,
    required String type,
    required String icon,
    required String color,
    required DateTime now,
  }) {
    return CategoriesCompanion.insert(
      id: id,
      userId: userId,
      name: name,
      type: type,
      icon: Value(icon),
      color: Value(color),
      isDefault: const Value(true),
      createdAt: now,
      updatedAt: now,
    );
  }
}
