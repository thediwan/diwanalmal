import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../backup/backup_background.dart';

/// Ensures Workmanager is initialized exactly once per process.
abstract final class BackgroundWorkmanagerRegistry {
  static bool _initialized = false;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Registers the background callback dispatcher (safe to call multiple times).
  static Future<void> ensureInitialized() async {
    if (!isSupported || _initialized) return;
    await Workmanager().initialize(backupCallbackDispatcher);
    _initialized = true;
  }
}
