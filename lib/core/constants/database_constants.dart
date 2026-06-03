/// Transaction, category, and debt type values stored in SQLite.
abstract final class DatabaseConstants {
  static const String txIncome = 'income';
  static const String txExpense = 'expense';

  static const String categoryIncome = 'income';
  static const String categoryExpense = 'expense';

  static const String debtOwedToMe = 'owed_to_me';
  static const String debtIOwe = 'i_owe';

  /// Demo user seeded for UI development.
  static const String seedUserId = '550e8400-e29b-41d4-a716-446655440000';
}
