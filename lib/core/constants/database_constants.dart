/// Transaction, category, and debt type values stored in SQLite.
abstract final class DatabaseConstants {
  static const String txIncome = 'income';
  static const String txExpense = 'expense';

  /// Receivable — someone owes the user (stored in [Transactions] + [Debts]).
  static const String txDebtor = 'debtor';

  /// Payable — the user owes someone (stored in [Transactions] + [Debts]).
  static const String txCreditor = 'creditor';

  /// Cross-currency wallet transfer (stored in [Transfers] table).
  static const String txCurrencyTransfer = 'currency_transfer';

  static bool isDebtLedgerType(String type) =>
      type == txDebtor || type == txCreditor;

  static const String categoryIncome = 'income';
  static const String categoryExpense = 'expense';

  static const String debtOwedToMe = 'owed_to_me';
  static const String debtIOwe = 'i_owe';

  /// Demo user seeded for UI development.
  static const String seedUserId = '550e8400-e29b-41d4-a716-446655440000';
}
