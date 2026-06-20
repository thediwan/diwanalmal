import 'package:intl/intl.dart';

import '../core/constants/database_constants.dart';
import '../core/constants/goal_icon_styles.dart';
import '../database/daos/finance_dao.dart';
import '../features/dashboard/models/dashboard_models.dart';
import '../l10n/app_localizations.dart';
import 'lazarus_database_service.dart';
import 'report_analytics_helper.dart';
import 'transaction_list_service.dart';

/// Loads dashboard UI data from Lazarus SQLite tables.
class DashboardService {
  DashboardService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  FinanceDao get _dao => _lazarus.database.financeDao;

  /// Monthly summary, goals, transactions, and chart from database.
  Future<DashboardSnapshot> loadSnapshot(
    AppLocalizations l10n, {
    required String localeName,
    required int deleteWindowHours,
    required int editWindowDays,
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

    await _dao.syncAllGoalSavedAmounts(userId);
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

    final recentPage = await TransactionListService(_lazarus).fetchPage(
      filter: const ActivityFeedFilter(),
      page: 0,
      baseCurrencyCode: baseCode,
      l10n: l10n,
      localeName: localeName,
      deleteWindowHours: deleteWindowHours,
      editWindowDays: editWindowDays,
    );

    final transactions = recentPage.items
        .take(8)
        .map(
          (item) => DashboardTransaction(
            title: item.title,
            subtitle: _formatTransactionSubtitle(
              item.transactionDate,
              localeName,
              l10n,
            ),
            primaryAmount: item.primaryAmount,
            secondaryAmount: item.secondaryAmount,
            kind: item.kind,
            icon: item.icon,
            iconColor: item.iconColor,
          ),
        )
        .toList();

    final dailyTotals = await _dao.getDailyExpenseTotals(userId, days: 35);
    final dailyChart = _buildDailyChartPoints(dailyTotals, localeName);
    final weeklyChart = _buildWeeklyChartPoints(dailyTotals, localeName);
    final changeMetrics =
        await ReportAnalyticsHelper(_lazarus).loadCurrentMonthChange();

    return DashboardSnapshot(
      monthlyIncome: income,
      monthlyExpense: expense,
      debts: debts,
      goals: goals,
      transactions: transactions,
      dailyChart: dailyChart,
      weeklyChart: weeklyChart,
      baseCurrencyCode: baseCode,
      incomeChangePct: changeMetrics.incomeChangePct,
      expenseChangePct: changeMetrics.expenseChangePct,
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

  /// Last 7 calendar days including today (zeros for days without spending).
  List<DashboardChartPoint> _buildDailyChartPoints(
    List<ChartDayTotal> totals,
    String localeName,
  ) {
    final today = _dayOnly(DateTime.now());
    final byDay = {for (final row in totals) _dayOnly(row.date): row.totalBase};

    return List.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return DashboardChartPoint(
        label: DateFormat.Md(localeName).format(day),
        amount: byDay[day] ?? 0,
      );
    });
  }

  /// Last 4 ISO weeks (Mon–Sun buckets) including the current week.
  List<DashboardChartPoint> _buildWeeklyChartPoints(
    List<ChartDayTotal> totals,
    String localeName,
  ) {
    final today = _dayOnly(DateTime.now());
    final currentWeekStart = _weekStart(today);

    final weekTotals = List<double>.filled(4, 0);
    for (final row in totals) {
      final day = _dayOnly(row.date);
      final weekStart = _weekStart(day);
      final diffWeeks = currentWeekStart.difference(weekStart).inDays ~/ 7;
      if (diffWeeks >= 0 && diffWeeks < 4) {
        weekTotals[3 - diffWeeks] += row.totalBase;
      }
    }

    return List.generate(4, (index) {
      final weekStart = currentWeekStart.subtract(Duration(days: (3 - index) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final label = index == 3
          ? DateFormat.Md(localeName).format(weekStart)
          : '${DateFormat.Md(localeName).format(weekStart)}–${DateFormat.Md(localeName).format(weekEnd)}';

      return DashboardChartPoint(
        label: label,
        amount: weekTotals[index],
      );
    });
  }

  DateTime _dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _weekStart(DateTime date) {
    final day = _dayOnly(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
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
    required this.baseCurrencyCode,
    this.incomeChangePct,
    this.expenseChangePct,
  });

  final double monthlyIncome;
  final double monthlyExpense;
  final double debts;
  final List<DashboardGoal> goals;
  final List<DashboardTransaction> transactions;
  final List<DashboardChartPoint> dailyChart;
  final List<DashboardChartPoint> weeklyChart;
  final String baseCurrencyCode;
  final double? incomeChangePct;
  final double? expenseChangePct;

  factory DashboardSnapshot.empty() {
    return const DashboardSnapshot(
      monthlyIncome: 0,
      monthlyExpense: 0,
      debts: 0,
      goals: [],
      transactions: [],
      dailyChart: [],
      weeklyChart: [],
      baseCurrencyCode: 'USD',
    );
  }
}
