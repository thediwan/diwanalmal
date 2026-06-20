import '../../features/reports/domain/entities/report_entities.dart';
import '../../features/reports/domain/insights/insight_rules.dart';
import '../../features/reports/domain/repositories/monthly_report_repository.dart';
import '../../features/reports/data/repositories/monthly_report_repository_impl.dart';
import 'goal_service.dart';
import 'lazarus_database_service.dart';

/// Orchestrates monthly report generation, surplus actions, and listing.
class MonthlyReportService {
  MonthlyReportService(LazarusDatabaseService lazarus, this._goalService)
      : _repository = MonthlyReportRepositoryImpl(
          database: lazarus.database,
          resolveActiveUserId: lazarus.getActiveUserId,
          insightEngine: createDefaultInsightEngine(),
        );

  final GoalService _goalService;
  final MonthlyReportRepository _repository;

  MonthlyReportRepository get repository => _repository;

  Future<MonthlyReportSnapshot?> getReport({
    required int year,
    required int month,
  }) =>
      _repository.getReport(year: year, month: month);

  Future<MonthlyReportSnapshot> ensureReport({
    required int year,
    required int month,
  }) async {
    final existing = await _repository.getReport(year: year, month: month);
    if (existing != null) return existing;
    return _repository.generateReport(year: year, month: month);
  }

  Future<MonthlyReportSnapshot> refreshReport({
    required int year,
    required int month,
  }) =>
      _repository.generateReport(year: year, month: month);

  Future<List<MonthlyReportSnapshot>> listReports() => _repository.listReports();

  Future<MonthlyReportSnapshot> carrySurplusForward({
    required int year,
    required int month,
    double? amount,
  }) =>
      _repository.carrySurplusForward(
        year: year,
        month: month,
        amount: amount,
      );

  Future<MonthlyReportSnapshot> allocateSurplusToGoal({
    required int year,
    required int month,
    required String goalId,
    required String sourceWalletId,
    required double amount,
  }) async {
    final report = await ensureReport(year: year, month: month);
    if (amount <= 0 || amount > report.availableSurplus + 0.000001) {
      throw ArgumentError('invalid_surplus_amount');
    }

    final reportDate = DateTime(year, month + 1, 0);
    await _goalService.deposit(
      goalId: goalId,
      sourceWalletId: sourceWalletId,
      amount: amount,
      date: reportDate,
      notes: 'monthly_report_surplus',
    );

    final action = amount >= report.availableSurplus - 0.000001
        ? SurplusAction.allocateGoal
        : SurplusAction.partial;

    return _repository.recordSurplusAllocation(
      year: year,
      month: month,
      allocatedAmount: amount,
      goalId: goalId,
      action: action,
    );
  }

  /// Generates draft report for the previous calendar month if missing.
  Future<MonthlyReportSnapshot?> ensurePreviousMonthReport() async {
    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1);
    final existing = await _repository.getReport(
      year: previous.year,
      month: previous.month,
    );
    if (existing != null) return existing;
    return _repository.generateReport(
      year: previous.year,
      month: previous.month,
    );
  }

  /// Auto carry-forward surplus after grace period when still pending.
  Future<void> autoFinalizeStaleDrafts({int graceDays = 7}) async {
    final reports = await _repository.listReports();
    final now = DateTime.now();

    for (final report in reports) {
      if (report.status != MonthlyReportStatus.draft) continue;

      final monthEnd = DateTime(report.year, report.month + 1);
      if (now.difference(monthEnd).inDays < graceDays) continue;

      if (report.hasPendingSurplus) {
        await _repository.carrySurplusForward(
          year: report.year,
          month: report.month,
        );
      } else {
        await _repository.carrySurplusForward(
          year: report.year,
          month: report.month,
          amount: 0,
        );
      }
    }
  }
}
