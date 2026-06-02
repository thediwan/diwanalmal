import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/hive_constants.dart';
import '../models/app_settings.dart';
import '../models/currency.dart';
import '../models/wallet.dart';

/// Initializes Hive and opens all required boxes.
class HiveService {
  static const String settingsKey = 'app_settings';

  Box<AppSettings>? _settingsBox;
  Box<Currency>? _currenciesBox;
  Box<Wallet>? _walletsBox;

  Box<AppSettings> get settingsBox => _settingsBox!;
  Box<Currency> get currenciesBox => _currenciesBox!;
  Box<Wallet> get walletsBox => _walletsBox!;

  /// Registers adapters and opens boxes. Must run before app start.
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HiveConstants.currencyTypeId)) {
      Hive.registerAdapter(CurrencyAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.walletTypeId)) {
      Hive.registerAdapter(WalletAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.appSettingsTypeId)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    _settingsBox = await Hive.openBox<AppSettings>(HiveConstants.settingsBox);
    _currenciesBox = await Hive.openBox<Currency>(HiveConstants.currenciesBox);
    _walletsBox = await Hive.openBox<Wallet>(HiveConstants.walletsBox);

    if (!_settingsBox!.containsKey(settingsKey)) {
      await _settingsBox!.put(settingsKey, AppSettings.initial());
    }
  }

  AppSettings getSettings() {
    return _settingsBox!.get(settingsKey) ?? AppSettings.initial();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox!.put(settingsKey, settings);
  }
}
