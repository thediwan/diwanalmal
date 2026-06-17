import 'package:drift/drift.dart';

import '../../core/constants/category_icon_styles.dart';
import '../../core/constants/database_constants.dart';
import '../lazarus_database.dart';

/// Ensures the two protected system categories exist for every user.
///
/// Independent of demo/test seed data ([SeedConstants]).
class SystemCategoryService {
  SystemCategoryService(this._db);

  final LazarusDatabase _db;

  /// Creates or restores general income + general expense categories.
  Future<void> ensureForUser(String userId) async {
    final now = DateTime.now();

    await _upsert(
      userId: userId,
      id: DatabaseConstants.systemGeneralIncomeCategoryId,
      name: 'دخل عام',
      type: DatabaseConstants.categoryIncome,
      icon: CategoryIconStyles.salary,
      color: '#16A34A',
      now: now,
    );

    await _upsert(
      userId: userId,
      id: DatabaseConstants.systemGeneralExpenseCategoryId,
      name: 'مصروف عام',
      type: DatabaseConstants.categoryExpense,
      icon: CategoryIconStyles.other,
      color: '#6B7280',
      now: now,
    );
  }

  Future<void> _upsert({
    required String userId,
    required String id,
    required String name,
    required String type,
    required String icon,
    required String color,
    required DateTime now,
  }) async {
    final existing = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(id))
          ..where((c) => c.userId.equals(userId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              id: id,
              userId: userId,
              name: name,
              type: type,
              icon: Value(icon),
              color: Value(color),
              isDefault: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }

    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        type: Value(type),
        icon: Value(icon),
        color: Value(color),
        isDefault: const Value(true),
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }
}
