import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/hive_service.dart';

/// Manages app settings including setup state and theme mode.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._hiveService) {
    _settings = _hiveService.getSettings();
  }

  final HiveService _hiveService;
  late AppSettings _settings;

  bool get isSetupComplete => _settings.isSetupComplete;
  String get baseCurrencyCode => _settings.baseCurrencyCode;
  ThemeMode get themeMode => _settings.themeMode;

  Future<void> refresh() async {
    _settings = _hiveService.getSettings();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> markSetupComplete(String baseCurrencyCode) async {
    _settings = _settings.copyWith(
      isSetupComplete: true,
      baseCurrencyCode: baseCurrencyCode,
    );
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }
}
