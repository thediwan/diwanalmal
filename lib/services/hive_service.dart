import 'dart:io';

import 'package:hive/hive.dart';

import '../core/constants/hive_constants.dart';
import '../core/helpers/app_storage_paths.dart';
import '../core/helpers/hive_lock_helper.dart';
import '../models/app_settings.dart';
import '../models/currency.dart';
import '../models/wallet.dart';

/// Initializes Hive and opens all required boxes.
class HiveService {
  static const String settingsKey = 'app_settings';
  static const int _maxOpenAttempts = 3;

  static String? _storagePath;

  Box<AppSettings>? _settingsBox;
  Box<Currency>? _currenciesBox;
  Box<Wallet>? _walletsBox;

  Box<AppSettings> get settingsBox => _settingsBox!;
  Box<Currency> get currenciesBox => _currenciesBox!;
  Box<Wallet> get walletsBox => _walletsBox!;

  /// Registers adapters and opens boxes. Must run before app start.
  Future<void> init() async {
    _storagePath = await AppStoragePaths.ensureDataDirectory();

    // Hot-restart recovery: close any boxes left from a prior isolate.
    try {
      await Hive.close();
    } catch (_) {}

    await HiveLockHelper.acquireInstanceLock(_storagePath!);
    await HiveLockHelper.clearStaleLockFiles(_storagePath!);

    Hive.init(_storagePath!);

    if (!Hive.isAdapterRegistered(HiveConstants.currencyTypeId)) {
      Hive.registerAdapter(CurrencyAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.walletTypeId)) {
      Hive.registerAdapter(WalletAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.appSettingsTypeId)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    _settingsBox =
        await _openBoxWithRetry<AppSettings>(HiveConstants.settingsBox);
    _currenciesBox =
        await _openBoxWithRetry<Currency>(HiveConstants.currenciesBox);
    _walletsBox = await _openBoxWithRetry<Wallet>(HiveConstants.walletsBox);

    if (!_settingsBox!.containsKey(settingsKey)) {
      await _settingsBox!.put(settingsKey, AppSettings.initial());
    } else {
      // Re-persist so legacy blobs gain policy int fields on disk.
      await saveSettings(getSettings());
    }
  }

  Future<Box<T>> _openBoxWithRetry<T>(String name) async {
    Object? lastError;
    for (var attempt = 0; attempt < _maxOpenAttempts; attempt++) {
      try {
        return await Hive.openBox<T>(name);
      } on PathAccessException catch (e) {
        lastError = e;
        if (_storagePath != null) {
          await HiveLockHelper.clearStaleLockFiles(_storagePath!);
        }
        if (attempt < _maxOpenAttempts - 1) {
          await Future<void>.delayed(
            Duration(milliseconds: 400 * (attempt + 1)),
          );
        }
      }
    }

    if (lastError != null) {
      throw AppStorageLockException(isAnotherInstance: true);
    }
    throw StateError('Failed to open Hive box "$name"');
  }

  AppSettings getSettings() {
    return _settingsBox!.get(settingsKey) ?? AppSettings.initial();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox!.put(settingsKey, settings);
  }

  /// Closes all open Hive boxes (required before restore).
  Future<void> closeAllBoxes() async {
    await _settingsBox?.close();
    await _currenciesBox?.close();
    await _walletsBox?.close();
    _settingsBox = null;
    _currenciesBox = null;
    _walletsBox = null;
  }

  /// Reopens boxes after a restore without re-running adapter registration.
  Future<void> reopen() async {
    if (_storagePath != null) {
      await HiveLockHelper.clearStaleLockFiles(_storagePath!);
    }
    _settingsBox =
        await _openBoxWithRetry<AppSettings>(HiveConstants.settingsBox);
    _currenciesBox =
        await _openBoxWithRetry<Currency>(HiveConstants.currenciesBox);
    _walletsBox = await _openBoxWithRetry<Wallet>(HiveConstants.walletsBox);

    if (!_settingsBox!.containsKey(settingsKey)) {
      await _settingsBox!.put(settingsKey, AppSettings.initial());
    }
  }
}
