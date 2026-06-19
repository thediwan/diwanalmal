import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../core/constants/backup_constants.dart';
import '../core/constants/hive_constants.dart';
import '../core/helpers/backup_schedule_helper.dart';
import '../database/lazarus_database.dart';
import '../models/app_settings.dart';
import 'hive_service.dart';
import 'lazarus_database_service.dart';

/// Result of a backup or restore operation.
class BackupOperationResult {
  const BackupOperationResult({
    required this.success,
    this.archivePath,
    this.completedAt,
    this.errorKey,
  });

  final bool success;
  final String? archivePath;
  final DateTime? completedAt;
  final String? errorKey;
}

/// Status snapshot for the backup settings UI.
class BackupStatus {
  const BackupStatus({
    required this.archivePath,
    required this.archiveExists,
    this.lastBackupAt,
    required this.isDue,
  });

  final String archivePath;
  final bool archiveExists;
  final DateTime? lastBackupAt;
  final bool isDue;
}

/// Creates, exports, and restores local `.dmbackup` archives.
class BackupService {
  BackupService(
    this._hiveService, {
    LazarusDatabase? database,
  }) : _database = database;

  final HiveService _hiveService;
  final LazarusDatabase? _database;

  /// Resolves the on-device automatic backup archive path.
  static Future<String> localArchivePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
      dir.path,
      BackupConstants.backupsSubdir,
      BackupConstants.archiveFileName,
    );
  }

  /// Resolves `lazarus.db` in app documents.
  static Future<String> databasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, BackupConstants.lazarusDbFileName);
  }

  /// Resolves app documents directory (Hive box files live here).
  static Future<String> documentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<BackupStatus> getStatus() async {
    final settings = _hiveService.getSettings();
    final path = await localArchivePath();
    final file = File(path);
    return BackupStatus(
      archivePath: path,
      archiveExists: file.existsSync(),
      lastBackupAt: settings.lastBackupAt,
      isDue: _isDue(settings),
    );
  }

  /// Runs scheduled backup: checkpoint, replace single archive, update timestamp.
  Future<BackupOperationResult> runScheduledBackup() async {
    final settings = _hiveService.getSettings();
    if (!settings.backupEnabled) {
      return const BackupOperationResult(success: false, errorKey: 'disabled');
    }

    try {
      final archivePath = await _createArchive(replaceExisting: true);
      final now = DateTime.now();
      await _hiveService.saveSettings(
        settings.copyWith(lastBackupAt: now),
      );
      return BackupOperationResult(
        success: true,
        archivePath: archivePath,
        completedAt: now,
      );
    } catch (_) {
      return const BackupOperationResult(success: false, errorKey: 'failed');
    }
  }

  /// Builds archive and opens system share sheet.
  Future<BackupOperationResult> exportBackup() async {
    try {
      final dbPath = await databasePath();
      if (_database != null) {
        await _database.customStatement('PRAGMA wal_checkpoint(FULL);');
      } else {
        await BackupService._checkpointFile(dbPath);
      }

      final tempDir = await getTemporaryDirectory();
      final exportPath = p.join(
        tempDir.path,
        'dewanalmal_export_${DateTime.now().millisecondsSinceEpoch}.dmbackup',
      );
      await _writeArchiveToPath(exportPath);

      await Share.shareXFiles(
        [XFile(exportPath, mimeType: 'application/octet-stream')],
        subject: BackupConstants.archiveFileName,
      );
      return BackupOperationResult(
        success: true,
        archivePath: exportPath,
        completedAt: DateTime.now(),
      );
    } catch (_) {
      return const BackupOperationResult(success: false, errorKey: 'export_failed');
    }
  }

  /// Restores from a picked `.dmbackup` file after closing open stores.
  Future<BackupOperationResult> importBackup(File pickedArchive) async {
    try {
      await _validateArchive(pickedArchive);
      await LazarusDatabaseService.instance.close();
      await _hiveService.closeAllBoxes();
      await _extractAndReplace(pickedArchive);
      await _hiveService.reopen();
      await LazarusDatabaseService.reinitialize(_hiveService);
      final now = DateTime.now();
      await _hiveService.saveSettings(
        _hiveService.getSettings().copyWith(lastBackupAt: now),
      );
      return BackupOperationResult(
        success: true,
        completedAt: now,
      );
    } catch (e) {
      try {
        await _hiveService.reopen();
        await LazarusDatabaseService.reinitialize(_hiveService);
      } catch (_) {}
      return BackupOperationResult(
        success: false,
        errorKey: e is BackupException ? e.messageKey : 'import_failed',
      );
    }
  }

  /// Background-safe backup without an open Drift connection.
  static Future<BackupOperationResult> runBackgroundBackup() async {
    try {
      final dbPath = await databasePath();
      await _checkpointFile(dbPath);
      final archivePath = await _createArchiveStatic(replaceExisting: true);
      await _persistLastBackupAtBackground(DateTime.now());
      return BackupOperationResult(
        success: true,
        archivePath: archivePath,
        completedAt: DateTime.now(),
      );
    } catch (_) {
      return const BackupOperationResult(success: false, errorKey: 'failed');
    }
  }

  bool _isDue(AppSettings settings) {
    return BackupScheduleHelper.isBackupDue(
      hour: settings.backupHour,
      minute: settings.backupMinute,
      enabled: settings.backupEnabled,
      lastBackupAt: settings.lastBackupAt,
    );
  }

  Future<String> _createArchive({required bool replaceExisting}) async {
    final dbPath = await databasePath();
    if (_database != null) {
      await _database.customStatement('PRAGMA wal_checkpoint(FULL);');
    } else {
      await _checkpointFile(dbPath);
    }
    return _createArchiveStatic(replaceExisting: replaceExisting);
  }

  static Future<void> _writeArchiveToPath(String archivePath) async {
    final docs = await documentsPath();
    final dbPath = p.join(docs, BackupConstants.lazarusDbFileName);
    if (!File(dbPath).existsSync()) {
      throw BackupException('missing_db');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final manifest = {
      'version': BackupConstants.manifestVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'appVersion': packageInfo.version,
      'schemaVersion': BackupConstants.maxSupportedSchemaVersion,
    };

    final archive = Archive();
    archive.addFile(
      ArchiveFile(
        BackupConstants.manifestFileName,
        utf8.encode(jsonEncode(manifest)).length,
        utf8.encode(jsonEncode(manifest)),
      ),
    );

    final dbBytes = await File(dbPath).readAsBytes();
    archive.addFile(
      ArchiveFile(
        BackupConstants.lazarusDbFileName,
        dbBytes.length,
        dbBytes,
      ),
    );

    for (final hiveName in BackupConstants.hiveBoxFileNames) {
      final hivePath = p.join(docs, hiveName);
      if (File(hivePath).existsSync()) {
        final hiveBytes = await File(hivePath).readAsBytes();
        archive.addFile(
          ArchiveFile(hiveName, hiveBytes.length, hiveBytes),
        );
      }
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw BackupException('zip_failed');
    }
    await Directory(p.dirname(archivePath)).create(recursive: true);
    await File(archivePath).writeAsBytes(encoded, flush: true);
  }

  static Future<String> _createArchiveStatic({
    required bool replaceExisting,
  }) async {
    final docs = await documentsPath();
    final backupDir = p.join(docs, BackupConstants.backupsSubdir);
    await Directory(backupDir).create(recursive: true);
    final archivePath = p.join(backupDir, BackupConstants.archiveFileName);

    if (replaceExisting && File(archivePath).existsSync()) {
      await File(archivePath).delete();
    }

    await _writeArchiveToPath(archivePath);
    return archivePath;
  }

  static Future<void> _checkpointFile(String dbPath) async {
    if (!File(dbPath).existsSync()) return;
    final db = sqlite.sqlite3.open(dbPath);
    try {
      db.execute('PRAGMA wal_checkpoint(FULL);');
    } finally {
      db.close();
    }
  }

  static Future<void> _validateArchive(File file) async {
    if (!file.existsSync()) {
      throw BackupException('invalid_archive');
    }
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final manifestFile = archive.files.firstWhere(
      (f) => f.name == BackupConstants.manifestFileName,
      orElse: () => throw BackupException('invalid_archive'),
    );
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
    final schema = manifest['schemaVersion'] as int? ?? 0;
    if (schema > BackupConstants.maxSupportedSchemaVersion) {
      throw BackupException('unsupported_schema');
    }
    final dbEntry = archive.files.any(
      (f) => f.name == BackupConstants.lazarusDbFileName && f.size > 0,
    );
    if (!dbEntry) {
      throw BackupException('invalid_archive');
    }
  }

  static Future<void> _extractAndReplace(File archiveFile) async {
    final docs = await documentsPath();
    final bytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive.files) {
      if (file.isFile) {
        final outPath = p.join(docs, file.name);
        if (file.name == BackupConstants.manifestFileName) continue;
        await File(outPath).writeAsBytes(file.content as List<int>);
      }
    }

    // Remove WAL sidecars if present after replace.
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('${p.join(docs, BackupConstants.lazarusDbFileName)}$suffix');
      if (sidecar.existsSync()) {
        await sidecar.delete();
      }
    }
  }

  static Future<void> _persistLastBackupAtBackground(DateTime at) async {
    final docs = await documentsPath();
    final hivePath = p.join(docs, '${HiveConstants.settingsBox}.hive');
    if (!File(hivePath).existsSync()) return;

    // Lightweight marker; full merge happens when app reads settings next time.
    final marker = p.join(
      docs,
      BackupConstants.backupsSubdir,
      'last_backup.marker',
    );
    await Directory(p.dirname(marker)).create(recursive: true);
    await File(marker).writeAsString(at.toIso8601String());
  }

  /// Merges background marker into Hive settings on app startup.
  Future<void> mergeBackgroundBackupMarker() async {
    final docs = await documentsPath();
    final marker = File(
      p.join(docs, BackupConstants.backupsSubdir, 'last_backup.marker'),
    );
    if (!marker.existsSync()) return;

    final raw = await marker.readAsString();
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return;

    final settings = _hiveService.getSettings();
    final last = settings.lastBackupAt;
    if (last == null || parsed.isAfter(last)) {
      await _hiveService.saveSettings(
        settings.copyWith(lastBackupAt: parsed),
      );
    }
    await marker.delete();
  }
}

/// Typed backup failure for UI message keys.
class BackupException implements Exception {
  BackupException(this.messageKey);

  final String messageKey;
}
