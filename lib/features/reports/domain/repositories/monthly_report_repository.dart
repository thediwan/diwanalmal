import '../entities/report_entities.dart';

/// Persistence contract for monthly financial reports.
abstract class MonthlyReportRepository {
  Future<MonthlyReportSnapshot?> getReport({
    required int year,
    required int month,
  });

  Future<MonthlyReportSnapshot> generateReport({
    required int year,
    required int month,
  });

  Future<List<MonthlyReportSnapshot>> listReports();

  Future<MonthlyReportSnapshot> carrySurplusForward({
    required int year,
    required int month,
    double? amount,
  });

  Future<MonthlyReportSnapshot> recordSurplusAllocation({
    required int year,
    required int month,
    required double allocatedAmount,
    required String goalId,
    required SurplusAction action,
  });

  Future<MonthlyReportSnapshot?> getPreviousReport({
    required int year,
    required int month,
  });
}
