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
  Currencies,
  Categories,
])
class FinanceDao extends DatabaseAccessor<LazarusDatabase>
    with _$FinanceDaoMixin {
  FinanceDao(super.db);

  /// Active wallets with currency code for UI.
  Future<List<WalletWithCurrency>> getActiveWallets(String userId) {
    final w = db.wallets;
    final c = db.currencies;
    final query = select(w).join([
      innerJoin(c, c.id.equalsExp(w.currencyId)),
    ])
      ..where(w.userId.equals(userId))
      ..where(w.deletedAt.isNull())
      ..where(w.isArchived.equals(false));

    return query.get().then(
          (rows) => rows
              .map(
                (row) => WalletWithCurrency(
                  wallet: row.readTable(w),
                  currencyCode: row.readTable(c).code,
                  currencyRateToBase: row.readTable(c).rateToBase,
                ),
              )
              .toList(),
        );
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

  /// Opening balance + operations for one wallet in its currency.
  Future<double> computeWalletBalance(String walletId) async {
    final wallet = await (select(db.wallets)
          ..where((w) => w.id.equals(walletId)))
        .getSingleOrNull();
    if (wallet == null) return 0;

    final currency = await (select(db.currencies)
          ..where((c) => c.id.equals(wallet.currencyId)))
        .getSingleOrNull();
    if (currency == null) return wallet.openingBalance;

    var balance = wallet.openingBalance;

    final txs = await (select(db.transactions)
          ..where((t) => t.walletId.equals(walletId))
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

class WalletWithCurrency {
  const WalletWithCurrency({
    required this.wallet,
    required this.currencyCode,
    required this.currencyRateToBase,
  });

  final DbWallet wallet;
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
