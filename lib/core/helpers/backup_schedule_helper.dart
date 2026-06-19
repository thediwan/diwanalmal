import 'package:flutter/material.dart';

/// Computes next scheduled backup instant and due checks.
abstract final class BackupScheduleHelper {
  /// Next local [DateTime] at or after [from] matching [hour]:[minute].
  static DateTime computeNextRun({
    required int hour,
    required int minute,
    DateTime? from,
  }) {
    final now = from ?? DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Whether automatic backup should run now (today's slot passed, not yet backed up today).
  static bool isBackupDue({
    required int hour,
    required int minute,
    required bool enabled,
    DateTime? lastBackupAt,
    DateTime? now,
  }) {
    if (!enabled) return false;

    final current = now ?? DateTime.now();
    final todaySlot = DateTime(
      current.year,
      current.month,
      current.day,
      hour,
      minute,
    );

    if (current.isBefore(todaySlot)) return false;

    if (lastBackupAt == null) return true;

    final lastDay = DateTime(
      lastBackupAt.year,
      lastBackupAt.month,
      lastBackupAt.day,
    );
    final today = DateTime(current.year, current.month, current.day);
    return lastDay.isBefore(today);
  }

  static TimeOfDay clampTime(int hour, int minute) {
    return TimeOfDay(
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
    );
  }
}
