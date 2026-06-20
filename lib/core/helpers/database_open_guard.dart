import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../constants/backup_constants.dart';
import 'app_storage_paths.dart';

/// Safety net around SQLite open/migrate — never deletes user data.
///
/// Before opening, copies the DB to a sidecar backup. On failure, applies
/// idempotent schema repairs and retries. As a last resort, restores the
/// sidecar backup and retries once more.
abstract final class DatabaseOpenGuard {
  static const _backupSuffix = '.startup-safe.bak';

  /// Runs [openDatabase] with pre-backup and recovery retries.
  static Future<T> openSafely<T>(Future<T> Function() openDatabase) async {
    final dir = await AppStoragePaths.ensureDataDirectory();
    final dbFile = File(p.join(dir, BackupConstants.lazarusDbFileName));

    if (dbFile.existsSync()) {
      await _writeSafetyBackup(dbFile);
    }

    try {
      return await openDatabase();
    } catch (first, firstStack) {
      debugPrint('DatabaseOpenGuard: open attempt 1 failed: $first');
      debugPrint('$firstStack');

      if (!dbFile.existsSync()) rethrow;

      await _applyEmergencyRepairs(dbFile.path);
      try {
        return await openDatabase();
      } catch (second, secondStack) {
        debugPrint('DatabaseOpenGuard: open attempt 2 failed: $second');
        debugPrint('$secondStack');

        await _restoreSafetyBackup(dbFile);
        await _applyEmergencyRepairs(dbFile.path);
        return await openDatabase();
      }
    }
  }

  static Future<void> _writeSafetyBackup(File dbFile) async {
    final backupFile = File('${dbFile.path}$_backupSuffix');
    await dbFile.copy(backupFile.path);
    await _copySidecarIfExists(dbFile.path, backupFile.path);
  }

  static Future<void> _restoreSafetyBackup(File dbFile) async {
    final backupFile = File('${dbFile.path}$_backupSuffix');
    if (!backupFile.existsSync()) return;

    await backupFile.copy(dbFile.path);
    await _copySidecarIfExists(backupFile.path, dbFile.path);
  }

  static Future<void> _copySidecarIfExists(String fromBase, String toBase) async {
    for (final suffix in ['-wal', '-shm']) {
      final from = File('$fromBase$suffix');
      if (!from.existsSync()) continue;
      await from.copy('$toBase$suffix');
    }
  }

  /// Idempotent repairs for known partial-upgrade states (no data deletion).
  static Future<void> _applyEmergencyRepairs(String dbPath) async {
    final db = sqlite.sqlite3.open(dbPath);
    try {
      final version = _readUserVersion(db);

      if (version >= 13 && !_tableExists(db, 'monthly_reports')) {
        _createMonthlyReportsTable(db);
        _createMonthlyReportsIndex(db);
        if (version < 14) {
          db.execute('PRAGMA user_version = 14');
        }
      } else if (version >= 14 && !_tableExists(db, 'monthly_reports')) {
        _createMonthlyReportsTable(db);
        _createMonthlyReportsIndex(db);
      } else if (_tableExists(db, 'monthly_reports')) {
        _createMonthlyReportsIndex(db);
      }
    } finally {
      db.close();
    }
  }

  static int _readUserVersion(sqlite.Database db) {
    final row = db.select('PRAGMA user_version');
    return row.first.columnAt(0) as int;
  }

  static bool _tableExists(sqlite.Database db, String name) {
    final rows = db.select(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [name],
    );
    return rows.isNotEmpty;
  }

  static void _createMonthlyReportsTable(sqlite.Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS monthly_reports (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL REFERENCES app_users(id),
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        status TEXT NOT NULL,
        base_currency_code TEXT NOT NULL,
        total_income REAL NOT NULL DEFAULT 0,
        total_expense REAL NOT NULL DEFAULT 0,
        surplus REAL NOT NULL DEFAULT 0,
        total_goal_savings REAL NOT NULL DEFAULT 0,
        savings_rate REAL NOT NULL DEFAULT 0,
        previous_carryover_in REAL NOT NULL DEFAULT 0,
        available_surplus REAL NOT NULL DEFAULT 0,
        income_change_pct REAL,
        expense_change_pct REAL,
        savings_change_pct REAL,
        surplus_action TEXT,
        allocated_amount REAL,
        goal_id TEXT REFERENCES goals(id),
        carried_forward_amount REAL,
        snapshot_json TEXT NOT NULL,
        generated_at INTEGER NOT NULL,
        finalized_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  static void _createMonthlyReportsIndex(sqlite.Database db) {
    db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_monthly_reports_user_period
      ON monthly_reports (user_id, year, month)
    ''');
  }
}
