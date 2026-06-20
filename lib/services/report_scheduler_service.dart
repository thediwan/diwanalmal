import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../backup/backup_background.dart';
import '../core/constants/report_constants.dart';
import 'hive_service.dart';

/// Schedules monthly report generation on the 1st of each month.
class ReportSchedulerService {
  ReportSchedulerService(this._hiveService);

  // Reserved for future report notification preferences in Hive.
  // ignore: unused_field
  final HiveService _hiveService;

  static const String _uniqueTaskName = 'dewanalmal_report_once';

  static bool get isBackgroundSchedulingSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> register() async {
    if (!isBackgroundSchedulingSupported) return;
    await Workmanager().initialize(backupCallbackDispatcher);
  }

  Future<void> scheduleNextMonthlyRun() async {
    if (!isBackgroundSchedulingSupported) return;

    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1, 0, 5);
    final delay = nextMonth.difference(now);
    if (delay.isNegative) return;

    await Workmanager().registerOneOffTask(
      _uniqueTaskName,
      ReportConstants.workmanagerTaskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Future<void> runCatchUpIfNeeded() async {
    await runReportBackgroundTask(showNotification: false);
  }
}
