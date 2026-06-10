import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/goal_icon_styles.dart';
import '../core/constants/database_constants.dart';
import '../core/helpers/currency_formatter.dart';
import '../database/daos/finance_dao.dart';
import '../features/dashboard/models/dashboard_models.dart';
import '../l10n/app_localizations.dart';
import 'lazarus_database_service.dart';

/// Loads dashboard UI data from Lazarus SQLite tables.
class DashboardService {
  DashboardService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  FinanceDao get _dao => _lazarus.database.financeDao;

  /// Monthly summary, goals, transactions, and chart from database.
  Future<DashboardSnapshot> loadSnapshot(
    AppLocalizations l10n, {
    required String localeName,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      return DashboardSnapshot.empty();
    }

    final baseCode = await _resolveBaseCurrencyCode(userId);
    final now = DateTime.now();
    final income = await _dao.sumTransactionsBaseAmount(
      userId: userId,
      type: DatabaseConstants.txIncome,
      year: now.year,
      month: now.month,
    );
    final expense = await _dao.sumTransactionsBaseAmount(
      userId: userId,
      type: DatabaseConstants.txExpense,
      year: now.year,
      month: now.month,
    );
    final debts = await _dao.sumOutstandingDebtsBase(
      userId: userId,
      debtType: DatabaseConstants.debtIOwe,
    );

    final goalRows = await _dao.getGoals(userId);
    final goals = goalRows
        .map(
          (g) => DashboardGoal(
            id: g.id,
            title: g.title,
            progressPercent: g.targetAmount <= 0
                ? 0
                : ((g.savedAmount / g.targetAmount) * 100)
                    .round()
                    .clamp(0, 100),
            icon: GoalIconStyles.iconFor(g.icon),
          ),
        )
        .toList();

    final txRows = await _dao.getRecentTransactions(userId, limit: 8);
    final transactions = txRows.map((row) {
      final tx = row.transaction;
      final isIncome = tx.type == DatabaseConstants.txIncome;
      final sign = isIncome ? '+' : '-';
      final showSecondary =
          row.currencyCode.toUpperCase() != baseCode.toUpperCase();
      return DashboardTransaction(
        title: tx.title,
        subtitle: _formatTransactionSubtitle(
          tx.transactionDate,
          localeName,
          l10n,
        ),
        primaryAmount:
            '${CurrencyFormatter.formatCodeFirst(tx.baseAmount, baseCode)}$sign',
        secondaryAmount: showSecondary
            ? CurrencyFormatter.formatCodeFirst(
                tx.amount,
                row.currencyCode,
              )
            : null,
        isIncome: isIncome,
        icon: isIncome
            ? CupertinoIcons.money_dollar_circle_fill
            : CupertinoIcons.bag_fill,
        iconColor: isIncome ? AppColors.success : AppColors.debtAccent,
      );
    }).toList();

    final dailyTotals = await _dao.getDailyExpenseTotals(userId, days: 30);
    final chartPoints = _buildChartPoints(dailyTotals, localeName);

    return DashboardSnapshot(
      monthlyIncome: income,
      monthlyExpense: expense,
      debts: debts,
      goals: goals,
      transactions: transactions,
      dailyChart: chartPoints,
      weeklyChart: chartPoints,
    );
  }

  String _formatTransactionSubtitle(
    DateTime date,
    String localeName,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(date.year, date.month, date.day);
    final time = DateFormat.jm(localeName).format(date);

    if (txDay == today) {
      return '${l10n.dashboardToday}، $time';
    }
    if (txDay == today.subtract(const Duration(days: 1))) {
      return '${l10n.dashboardYesterday}، $time';
    }
    return DateFormat.yMMMd(localeName).add_jm().format(date);
  }

  List<DashboardChartPoint> _buildChartPoints(
    List<ChartDayTotal> totals,
    String localeName,
  ) {
    if (totals.isEmpty) {
      return const [
        DashboardChartPoint(label: '—', value: 0.2),
        DashboardChartPoint(label: '—', value: 0.2),
      ];
    }

    final maxVal =
        totals.map((e) => e.totalBase).reduce((a, b) => a > b ? a : b);
    final denom = maxVal > 0 ? maxVal : 1;

    if (totals.length <= 4) {
      return totals
          .map(
            (e) => DashboardChartPoint(
              label: DateFormat.Md(localeName).format(e.date),
              value: (e.totalBase / denom).clamp(0.05, 1.0),
            ),
          )
          .toList();
    }

    final step = (totals.length / 4).ceil();
    final picked = <ChartDayTotal>[];
    for (var i = 0; i < totals.length; i += step) {
      picked.add(totals[i]);
    }
    if (picked.last != totals.last) picked.add(totals.last);

    return picked
        .map(
          (e) => DashboardChartPoint(
            label: DateFormat.Md(localeName).format(e.date),
            value: (e.totalBase / denom).clamp(0.05, 1.0),
          ),
        )
        .toList();
  }

  Future<String> _resolveBaseCurrencyCode(String userId) async {
    final settings = await (_lazarus.database.select(_lazarus.database.userSettings)
          ..where((s) => s.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();
    if (settings == null) return 'USD';

    final currency = await (_lazarus.database.select(_lazarus.database.currencies)
          ..where((c) => c.id.equals(settings.baseCurrencyId))
          ..limit(1))
        .getSingleOrNull();
    return currency?.code ?? 'USD';
  }
}

/// Aggregated dashboard metrics for one render pass.
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.debts,
    required this.goals,
    required this.transactions,
    required this.dailyChart,
    required this.weeklyChart,
  });

  final double monthlyIncome;
  final double monthlyExpense;
  final double debts;
  final List<DashboardGoal> goals;
  final List<DashboardTransaction> transactions;
  final List<DashboardChartPoint> dailyChart;
  final List<DashboardChartPoint> weeklyChart;

  factory DashboardSnapshot.empty() {
    return const DashboardSnapshot(
      monthlyIncome: 0,
      monthlyExpense: 0,
      debts: 0,
      goals: [],
      transactions: [],
      dailyChart: [],
      weeklyChart: [],
    );
  }
}
