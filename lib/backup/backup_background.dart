import 'package:workmanager/workmanager.dart';

import '../core/constants/backup_constants.dart';
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

/// Re-export dispatcher used by [BackupSchedulerService.register].
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != BackupConstants.workmanagerTaskName) {
      return true;
    }
    return runBackupBackgroundTask();
  });
}
