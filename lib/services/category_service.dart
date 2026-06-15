import '../core/constants/database_constants.dart';
import '../database/lazarus_database.dart';
import '../models/transaction_category.dart';
import 'lazarus_database_service.dart';

/// Loads transaction categories from Lazarus SQLite.
class CategoryService {
  CategoryService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Expense categories for the active user.
  Future<List<TransactionCategory>> getExpenseCategories() {
    return _getByType(DatabaseConstants.categoryExpense);
  }

  /// Income categories for the active user.
  Future<List<TransactionCategory>> getIncomeCategories() {
    return _getByType(DatabaseConstants.categoryIncome);
  }

  Future<List<TransactionCategory>> _getByType(String type) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final rows = await _db.financeDao.getCategoriesByType(
      userId: userId,
      type: type,
    );

    return rows
        .map(
          (row) => TransactionCategory(
            id: row.id,
            name: row.name,
            type: row.type,
            iconKey: row.icon,
            colorHex: row.color,
            isDefault: row.isDefault,
          ),
        )
        .toList();
  }
}
