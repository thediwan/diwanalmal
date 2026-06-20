import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../core/constants/backup_constants.dart';
import '../core/helpers/backup_schedule_helper.dart';
import '../models/app_settings.dart';
import 'backup_notification_service.dart';
import 'backup_service.dart';
import 'hive_service.dart';

  /// Schedules daily one-off WorkManager backups and resume catch-up.
  ///
  /// Call [BackgroundWorkmanagerRegistry.ensureInitialized] once from [main]
  /// before using this service on mobile.
class BackupSchedulerService {
  BackupSchedulerService(this._hiveService, this._backupService);

  final HiveService _hiveService;
  final BackupService _backupService;

  static const String _uniqueTaskName = 'dewanalmal_backup_once';

  /// Whether WorkManager background scheduling is available on this platform.
  static bool get isBackgroundSchedulingSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// No-op — Workmanager is initialized via [BackgroundWorkmanagerRegistry].
  static Future<void> register() async {}

  /// Schedules the next run from current Hive settings.
  Future<void> scheduleFromSettings() async {
    if (!isBackgroundSchedulingSupported) return;

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
      if (isBackgroundSchedulingSupported) {
        await _scheduleNext(_hiveService.getSettings());
      }
      if (BackupNotificationService.isSupported) {
        await BackupNotificationService.showBackupSuccess(
          title: 'Dewan Almal',
          body: 'Backup completed successfully',
        );
      }
    }
  }

  Future<void> _scheduleNext(AppSettings settings) async {
    if (!isBackgroundSchedulingSupported) return;

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
