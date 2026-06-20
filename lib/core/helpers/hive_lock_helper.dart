import 'dart:io';

import 'package:path/path.dart' as p;

/// Thrown when local Hive storage cannot be opened.
class AppStorageLockException implements Exception {
  AppStorageLockException({required this.isAnotherInstance});

  /// True when another live process holds the storage lock.
  final bool isAnotherInstance;

  @override
  String toString() => isAnotherInstance
      ? 'AppStorageLockException: another instance is running'
      : 'AppStorageLockException: could not open local storage';
}

/// Process-wide lock + stale Hive `.lock` file recovery on desktop.
abstract final class HiveLockHelper {
  static RandomAccessFile? _instanceLock;

  /// Acquires an exclusive app-instance lock before Hive opens any box.
  static Future<void> acquireInstanceLock(String storagePath) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;

    final lockFile = File(p.join(storagePath, 'app_instance.lock'));
    await lockFile.parent.create(recursive: true);
    if (!lockFile.existsSync()) {
      await lockFile.create(recursive: true);
    }

    try {
      _instanceLock ??= await lockFile.open(mode: FileMode.write);
      await _instanceLock!.lock(FileLock.exclusive);
    } on PathAccessException {
      throw AppStorageLockException(isAnotherInstance: true);
    }
  }

  /// Removes orphaned Hive `.lock` files when no process holds them.
  static Future<void> clearStaleLockFiles(String storagePath) async {
    final dir = Directory(storagePath);
    if (!dir.existsSync()) return;

    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.lock')) continue;
      if (p.basename(entity.path) == 'app_instance.lock') continue;
      await _tryRemoveStaleLockFile(entity);
    }
  }

  static Future<bool> _tryRemoveStaleLockFile(File file) async {
    RandomAccessFile? handle;
    try {
      handle = await file.open(mode: FileMode.write);
      await handle.lock(FileLock.exclusive);
      await handle.unlock();
      await handle.close();
      handle = null;
      if (file.existsSync()) {
        await file.delete();
      }
      return true;
    } on PathAccessException {
      return false;
    } finally {
      await handle?.close();
    }
  }
}
