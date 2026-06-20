import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/backup_constants.dart';
import '../constants/hive_constants.dart';

/// Resolves the on-device directory for Hive, SQLite, backups, and avatars.
///
/// Desktop platforms use [getApplicationSupportDirectory] to avoid OneDrive /
/// cloud-synced Documents folders that can lock Hive `.lock` files on Windows.
abstract final class AppStoragePaths {
  static bool get _useSupportDirectory =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Ensures the data directory exists and returns its absolute path.
  static Future<String> ensureDataDirectory() async {
    if (_useSupportDirectory) {
      final supportDir = await getApplicationSupportDirectory();
      await Directory(supportDir.path).create(recursive: true);
      await _migrateLegacyDesktopDataIfNeeded(supportDir.path);
      return supportDir.path;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    await Directory(docsDir.path).create(recursive: true);
    return docsDir.path;
  }

  /// Copies legacy Hive / SQLite / backup files from Documents → App Support.
  static Future<void> _migrateLegacyDesktopDataIfNeeded(
    String supportPath,
  ) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final legacyPath = docsDir.path;
    if (p.equals(legacyPath, supportPath)) return;

    final legacySettings = File(
      p.join(legacyPath, '${HiveConstants.settingsBox}.hive'),
    );
    final supportSettings = File(
      p.join(supportPath, '${HiveConstants.settingsBox}.hive'),
    );
    if (!legacySettings.existsSync() || supportSettings.existsSync()) return;

    await _copyFileIfExists(
      p.join(legacyPath, '${HiveConstants.settingsBox}.hive'),
      p.join(supportPath, '${HiveConstants.settingsBox}.hive'),
    );
    for (final hiveName in BackupConstants.hiveBoxFileNames) {
      if (hiveName == '${HiveConstants.settingsBox}.hive') continue;
      await _copyFileIfExists(
        p.join(legacyPath, hiveName),
        p.join(supportPath, hiveName),
      );
    }

    for (final suffix in ['', '-wal', '-shm']) {
      await _copyFileIfExists(
        p.join(legacyPath, '${BackupConstants.lazarusDbFileName}$suffix'),
        p.join(supportPath, '${BackupConstants.lazarusDbFileName}$suffix'),
      );
    }

    await _copyDirectoryIfExists(
      p.join(legacyPath, BackupConstants.backupsSubdir),
      p.join(supportPath, BackupConstants.backupsSubdir),
    );
    await _copyDirectoryIfExists(
      p.join(legacyPath, 'avatars'),
      p.join(supportPath, 'avatars'),
    );
  }

  static Future<void> _copyFileIfExists(String from, String to) async {
    final source = File(from);
    if (!source.existsSync()) return;
    await source.copy(to);
  }

  static Future<void> _copyDirectoryIfExists(String from, String to) async {
    final source = Directory(from);
    if (!source.existsSync()) return;
    await for (final entity in source.list(recursive: true)) {
      final relative = p.relative(entity.path, from: from);
      final destPath = p.join(to, relative);
      if (entity is File) {
        await Directory(p.dirname(destPath)).create(recursive: true);
        await entity.copy(destPath);
      } else if (entity is Directory) {
        await Directory(destPath).create(recursive: true);
      }
    }
  }
}
