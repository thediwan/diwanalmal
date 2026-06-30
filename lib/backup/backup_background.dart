import 'package:workmanager/workmanager.dart';

import '../core/constants/backup_constants.dart';
import '../core/constants/report_constants.dart';
import '../database/lazarus_database.dart';
import '../features/reports/data/repositories/monthly_report_repository_impl.dart';
import '../features/reports/domain/insights/insight_rules.dart';
import '../services/backup_notification_service.dart';
import '../services/backup_service.dart';

/// WorkManager task body — kept separate for the entry-point import in main.
@pragma('vm:entry-point')
Future<bool> runBackupBackgroundTask() async {
  final result = await BackupService.runBackgroundBackup();
  if (result.success) {
    await BackupNotificationService.initialize();
    await BackupNotificationService.showBackupSuccess(
      title: 'Dewan Almal',
      body: 'Backup completed successfully',
    );
  }
  return result.success;
}

/// Generates the previous month's financial report.
@pragma('vm:entry-point')
Future<bool> runReportBackgroundTask({bool showNotification = false}) async {
  try {
    final db = await LazarusDatabase.open();
    final userId = await db.getActiveUserId();
    if (userId == null) {
      await db.close();
      return false;
    }

    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1);
    final repo = MonthlyReportRepositoryImpl(
      database: db,
      resolveActiveUserId: db.getActiveUserId,
      insightEngine: createDefaultInsightEngine(),
    );

    final existing = await repo.getReport(
      year: previous.year,
      month: previous.month,
    );
    if (existing == null) {
      await repo.generateReport(year: previous.year, month: previous.month);
    }

    await db.close();

    if (showNotification && BackupNotificationService.isSupported) {
      await BackupNotificationService.initialize();
      await BackupNotificationService.showBackupSuccess(
        title: 'Dewan Almal',
        body: 'Your monthly report is ready',
      );
    }
    return true;
  } catch (_) {
    return false;
  }
}

/// Re-export dispatcher used by schedulers.
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackupConstants.workmanagerTaskName) {
      return runBackupBackgroundTask();
    }
    if (task == ReportConstants.workmanagerTaskName) {
      return runReportBackgroundTask(showNotification: true);
    }
    return true;
  });
}
