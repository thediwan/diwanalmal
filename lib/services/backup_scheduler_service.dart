import 'package:workmanager/workmanager.dart';

import '../backup/backup_background.dart';
import '../core/constants/backup_constants.dart';
import '../core/helpers/backup_schedule_helper.dart';
import '../models/app_settings.dart';
import 'backup_notification_service.dart';
import 'backup_service.dart';
import 'hive_service.dart';

/// Schedules daily one-off WorkManager backups and resume catch-up.
class BackupSchedulerService {
  BackupSchedulerService(this._hiveService, this._backupService);

  final HiveService _hiveService;
  final BackupService _backupService;

  static const String _uniqueTaskName = 'dewanalmal_backup_once';

  /// Registers WorkManager callback (call once from [main]).
  static Future<void> register() async {
    await Workmanager().initialize(
      backupCallbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Schedules the next run from current Hive settings.
  Future<void> scheduleFromSettings() async {
    final settings = _hiveService.getSettings();
    if (!settings.backupEnabled) {
      await Workmanager().cancelByUniqueName(_uniqueTaskName);
      return;
    }
    await _scheduleNext(settings);
  }

  /// Reschedules after the user changes backup time or toggle.
  Future<void> reschedule() async {
    await scheduleFromSettings();
  }

  /// Runs backup immediately if today's slot passed and not yet backed up.
  Future<void> runCatchUpIfDue({required void Function() onSettingsChanged}) async {
    final settings = _hiveService.getSettings();
    if (!BackupScheduleHelper.isBackupDue(
      hour: settings.backupHour,
      minute: settings.backupMinute,
      enabled: settings.backupEnabled,
      lastBackupAt: settings.lastBackupAt,
    )) {
      return;
    }

    final result = await _backupService.runScheduledBackup();
    if (result.success) {
      onSettingsChanged();
      await _scheduleNext(_hiveService.getSettings());
      await BackupNotificationService.showBackupSuccess(
        title: 'Dewan Almal',
        body: 'Backup completed successfully',
      );
    }
  }

  Future<void> _scheduleNext(AppSettings settings) async {
    final next = BackupScheduleHelper.computeNextRun(
      hour: settings.backupHour,
      minute: settings.backupMinute,
    );
    final delay = next.difference(DateTime.now());
    if (delay.isNegative) return;

    await Workmanager().registerOneOffTask(
      _uniqueTaskName,
      BackupConstants.workmanagerTaskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
