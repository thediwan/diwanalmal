import 'package:drift/drift.dart';

import '../lazarus_database.dart';
import '../tables/schema_tables.dart';

part 'finance_dao.g.dart';

/// Aggregations and lists for dashboard and reports.
@DriftAccessor(tables: [
  Transactions,
  Transfers,
  Debts,
  DebtPayments,
  Goals,
  Wallets,
  WalletCurrencyAccounts,
  Currencies,
  Categories,
])
class FinanceDao extends DatabaseAccessor<LazarusDatabase>
    with _$FinanceDaoMixin {
  FinanceDao(super.db);

  /// Active treasuries with their currency account rows.
  Future<List<TreasuryWithAccounts>> getActiveTreasuries(String userId) async {
    final walletRows = await (select(db.wallets)
          ..where((w) => w.userId.equals(userId))
          ..where((w) => w.deletedAt.isNull())
          ..where((w) => w.isArchived.equals(false))
          ..orderBy([(w) => OrderingTerm.asc(w.name)]))
        .get();

    final result = <TreasuryWithAccounts>[];

    for (final wallet in walletRows) {
      final accounts = await _getAccountsForWallet(wallet.id);
      result.add(TreasuryWithAccounts(wallet: wallet, accounts: accounts));
    }

    return result;
  }

  Future<List<WalletAccountWithCurrency>> _getAccountsForWallet(
    String walletId,
  ) async {
    final a = db.walletCurrencyAccounts;
    final c = db.currencies;
    final query = select(a).join([
      innerJoin(c, c.id.equalsExp(a.currencyId)),
    ])
      ..where(a.walletId.equals(walletId))
      ..where(a.deletedAt.isNull());

    final rows = await query.get();
    return rows
        .map(
          (row) => WalletAccountWithCurrency(
            account: row.readTable(a),
            currencyCode: row.readTable(c).code,
            currencyRateToBase: row.readTable(c).rateToBase,
          ),
        )
        .toList();
  }

  /// Sum of base_amount for income/expense in calendar month.
  Future<double> sumTransactionsBaseAmount({
    required String userId,
    required String type,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final expr = db.transactions.baseAmount.sum();
    final query = selectOnly(db.transactions)
      ..addColumns([expr])
      ..where(db.transactions.userId.equals(userId))
      ..where(db.transactions.type.equals(type))
      ..where(db.transactions.deletedAt.isNull())
      ..where(db.transactions.transactionDate.isBiggerOrEqualValue(start))
      ..where(db.transactions.transactionDate.isSmallerThanValue(end));

    final row = await query.getSingleOrNull();
    return row?.read(expr) ?? 0;
  }

  /// Outstanding debt in base currency minus partial payments.
  Future<double> sumOutstandingDebtsBase({
    required String userId,
    required String debtType,
  }) async {
    final debtRows = await (select(db.debts)
          ..where((d) => d.userId.equals(userId))
          ..where((d) => d.type.equals(debtType))
          ..where((d) => d.isPaid.equals(false))
          ..where((d) => d.deletedAt.isNull()))
        .get();

    var total = 0.0;
    for (final debt in debtRows) {
      final paidExpr = db.debtPayments.baseAmount.sum();
      final paidRow = await (selectOnly(db.debtPayments)
            ..addColumns([paidExpr])
            ..where(db.debtPayments.debtId.equals(debt.id)))
          .getSingleOrNull();
      final paid = paidRow?.read(paidExpr) ?? 0;
      total += debt.baseAmount - paid;
    }
    return total;
  }

  /// Financial goals for dashboard.
  Future<List<FinancialGoal>> getGoals(String userId) {
    return (select(db.goals)..where((g) => g.userId.equals(userId))).get();
  }

  /// Recent transactions newest first.
  Future<List<TransactionWithMeta>> getRecentTransactions(
    String userId, {
    int limit = 10,
  }) {
    final t = db.transactions;
    final c = db.currencies;
    final query = select(t).join([
      innerJoin(c, c.id.equalsExp(t.currencyId)),
    ])
      ..where(t.userId.equals(userId))
      ..where(t.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(t.transactionDate)])
      ..limit(limit);

    return query.get().then(
          (rows) => rows
              .map(
                (row) => TransactionWithMeta(
                  transaction: row.readTable(t),
                  currencyCode: row.readTable(c).code,
                ),
              )
              .toList(),
        );
  }

  /// Daily expense totals (base) for chart — last [days] days.
  Future<List<ChartDayTotal>> getDailyExpenseTotals(
    String userId, {
    int days = 30,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await (select(db.transactions)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.type.equals('expense'))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.transactionDate.isBiggerOrEqualValue(since)))
        .get();

    final byDay = <DateTime, double>{};
    for (final row in rows) {
      final day = DateTime(
        row.transactionDate.year,
        row.transactionDate.month,
        row.transactionDate.day,
      );
      byDay[day] = (byDay[day] ?? 0) + row.baseAmount;
    }

    final sorted = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted
        .map((e) => ChartDayTotal(date: e.key, totalBase: e.value))
        .toList();
  }

  /// Opening balance + operations for one treasury currency account.
  Future<double> computeAccountBalance({
    required String walletId,
    required String currencyId,
  }) async {
    final account = await (select(db.walletCurrencyAccounts)
          ..where((a) => a.walletId.equals(walletId))
          ..where((a) => a.currencyId.equals(currencyId))
          ..where((a) => a.deletedAt.isNull()))
        .getSingleOrNull();

    final currency = await (select(db.currencies)
          ..where((c) => c.id.equals(currencyId)))
        .getSingleOrNull();
    if (currency == null) return account?.openingBalance ?? 0;

    var balance = account?.openingBalance ?? 0;

    final txs = await (select(db.transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    for (final tx in txs) {
      final inWallet = _amountInWalletCurrency(
        amount: tx.amount,
        txCurrencyId: tx.currencyId,
        txRate: tx.exchangeRate,
        walletCurrency: currency,
      );
      if (tx.type == 'income') {
        balance += inWallet;
      } else if (tx.type == 'expense') {
        balance -= inWallet;
      }
    }

    final transfersOut = await (select(db.transfers)
          ..where((t) => t.fromWalletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    for (final tr in transfersOut) {
      balance -= _amountInWalletCurrency(
        amount: tr.amount,
        txCurrencyId: tr.currencyId,
        txRate: tr.exchangeRate,
        walletCurrency: currency,
      );
    }

    final transfersIn = await (select(db.transfers)
          ..where((t) => t.toWalletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    for (final tr in transfersIn) {
      balance += _amountInWalletCurrency(
        amount: tr.amount,
        txCurrencyId: tr.currencyId,
        txRate: tr.exchangeRate,
        walletCurrency: currency,
      );
    }

    return balance;
  }

  /// Backward-compatible alias keyed by wallet id only (first account).
  Future<double> computeWalletBalance(String walletId) async {
    final account = await (select(db.walletCurrencyAccounts)
          ..where((a) => a.walletId.equals(walletId))
          ..where((a) => a.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (account == null) return 0;
    return computeAccountBalance(
      walletId: walletId,
      currencyId: account.currencyId,
    );
  }

  double _amountInWalletCurrency({
    required double amount,
    required String txCurrencyId,
    required double txRate,
    required DbCurrency walletCurrency,
  }) {
    if (txCurrencyId == walletCurrency.id) return amount;
    final base = amount * txRate;
    if (walletCurrency.rateToBase == 0) return 0;
    return base / walletCurrency.rateToBase;
  }
}

class TreasuryWithAccounts {
  const TreasuryWithAccounts({
    required this.wallet,
    required this.accounts,
  });

  final DbWallet wallet;
  final List<WalletAccountWithCurrency> accounts;
}

class WalletAccountWithCurrency {
  const WalletAccountWithCurrency({
    required this.account,
    required this.currencyCode,
    required this.currencyRateToBase,
  });

  final DbWalletCurrencyAccount account;
  final String currencyCode;
  final double currencyRateToBase;
}

class TransactionWithMeta {
  const TransactionWithMeta({
    required this.transaction,
    required this.currencyCode,
  });

  final Transaction transaction;
  final String currencyCode;
}

class ChartDayTotal {
  const ChartDayTotal({required this.date, required this.totalBase});

  final DateTime date;
  final double totalBase;
}
