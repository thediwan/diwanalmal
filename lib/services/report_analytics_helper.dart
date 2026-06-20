import '../../database/daos/finance_dao.dart';
import '../../services/lazarus_database_service.dart';

/// Shared month-over-month analytics for dashboard and reports.
class ReportAnalyticsHelper {
  ReportAnalyticsHelper(this._lazarus);

  final LazarusDatabaseService _lazarus;

  FinanceDao get _dao => _lazarus.database.financeDao;

  Future<MonthlyChangeMetrics> loadCurrentMonthChange() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return MonthlyChangeMetrics.empty();

    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);

    final currentIncome = await _dao.sumMonthlyIncomeBase(
      userId: userId,
      year: now.year,
      month: now.month,
    );
    final prevIncome = await _dao.sumMonthlyIncomeBase(
      userId: userId,
      year: prev.year,
      month: prev.month,
    );
    final currentExpense = await _dao.sumMonthlyExpenseBase(
      userId: userId,
      year: now.year,
      month: now.month,
    );
    final prevExpense = await _dao.sumMonthlyExpenseBase(
      userId: userId,
      year: prev.year,
      month: prev.month,
    );

    return MonthlyChangeMetrics(
      incomeChangePct: _percentChange(currentIncome, prevIncome),
      expenseChangePct: _percentChange(currentExpense, prevExpense),
    );
  }

  double? _percentChange(double current, double previous) {
    if (previous.abs() < 0.000001) return null;
    return ((current - previous) / previous) * 100;
  }
}

class MonthlyChangeMetrics {
  const MonthlyChangeMetrics({
    this.incomeChangePct,
    this.expenseChangePct,
  });

  final double? incomeChangePct;
  final double? expenseChangePct;

  factory MonthlyChangeMetrics.empty() => const MonthlyChangeMetrics();
}
