import 'package:flutter/material.dart';

import '../core/constants/transaction_policy.dart';
import '../core/helpers/currency_formatter.dart';
import '../core/theme/palettes/app_color_palette.dart';
import '../models/amount_format_style.dart';
import '../models/app_settings.dart';
import '../models/font_size_preference.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/hive_service.dart';
import '../services/profile_service.dart';

/// Manages app settings, registration, and session lock state.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._hiveService,
    this._authService,
    this._biometricService,
    this._profileService,
  ) {
    _settings = _hiveService.getSettings();
    CurrencyFormatter.configureFromStyle(_settings.amountFormatStyle);
    _syncMustShowSecurityCode();
  }

  void _syncMustShowSecurityCode() {
    _mustShowSecurityCode = _settings.isSecuritySetupComplete &&
        !_settings.securityCodeAcknowledged &&
        _settings.securityCode.isNotEmpty;
  }

  final HiveService _hiveService;
  final AuthService _authService;
  final BiometricService _biometricService;
  final ProfileService _profileService;

  late AppSettings _settings;
  bool _isSessionUnlocked = false;

  /// In-memory until user taps Next on the security code screen.
  bool _mustShowSecurityCode = false;

  /// Code shown on security screen (survives redirect without [GoRouter] extra).
  String _displaySecurityCode = '';

  bool get isSetupComplete => _settings.isSetupComplete;
  String get baseCurrencyCode => _settings.baseCurrencyCode;
  ThemeMode get themeMode => _settings.themeMode;
  AppColorPaletteId get colorPaletteId => _settings.colorPaletteId;
  Locale get locale => Locale(_settings.localeCode);
  bool get hasAccount => _settings.hasAccount;
  bool get isSecuritySetupComplete => _settings.isSecuritySetupComplete;
  bool get biometricEnabled => _settings.biometricEnabled;
  String get securityCode => _settings.securityCode;

  int get transactionDeleteWindowHours {
    final hours = _settings.transactionDeleteWindowHours;
    return hours > 0 ? hours : TransactionPolicyDefaults.deleteWindowHours;
  }

  int get transactionEditWindowDays {
    final days = _settings.transactionEditWindowDays;
    return days > 0 ? days : TransactionPolicyDefaults.editWindowDays;
  }

  /// Thousands / decimal separators for monetary amounts.
  AmountFormatStyle get amountFormatStyle => _settings.amountFormatStyle;

  /// App-wide font size preset (Default / Large / Extra Large).
  FontSizePreference get fontSizePreference => _settings.fontSizePreference;

  /// Best available code for the security screen (memory, then Hive).
  String get displaySecurityCode =>
      _displaySecurityCode.isNotEmpty ? _displaySecurityCode : securityCode;

  bool get isSessionUnlocked => _isSessionUnlocked;

  /// User must view the recovery security code before onboarding.
  bool get needsSecurityCodeScreen =>
      _mustShowSecurityCode ||
      (isSecuritySetupComplete &&
          !_settings.securityCodeAcknowledged &&
          securityCode.isNotEmpty);

  /// App requires PIN or biometric before entering main flow.
  bool get requiresUnlock =>
      hasAccount && isSecuritySetupComplete && !_isSessionUnlocked;

  Future<void> refresh() async {
    _settings = _hiveService.getSettings();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setColorPalette(AppColorPaletteId paletteId) async {
    _settings = _settings.copyWith(colorPaletteKey: paletteId.storageKey);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode == 'en' ? 'en' : 'ar';
    _settings = _settings.copyWith(localeCode: code);
    await _hiveService.saveSettings(_settings);
    await _profileService.syncLanguage(code);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _settings = _settings.copyWith(biometricEnabled: enabled);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updatePin(String newPin) async {
    await _authService.updatePin(newPin);
    _settings = _hiveService.getSettings();
    notifyListeners();
  }

  /// Persists amount grouping style (settings screen will call this later).
  Future<void> setAmountFormatStyle(AmountFormatStyle style) async {
    _settings = _settings.copyWith(amountFormatStyleIndex: style.storageIndex);
    CurrencyFormatter.configureFromStyle(style);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setFontSizePreference(FontSizePreference preference) async {
    _settings = _settings.copyWith(
      fontSizePreferenceIndex: preference.storageIndex,
    );
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

  Future<void> registerAccount({
    required String username,
    required String password,
  }) async {
    await _authService.register(
      username: username,
      password: password,
      securityCode: '',
    );
    _settings = _hiveService.getSettings();
    _mustShowSecurityCode = false;
    _displaySecurityCode = '';
    _isSessionUnlocked = false;
  }

  /// Reloads settings from storage and notifies listeners (e.g. after navigation).
  void reloadFromStorage() {
    _settings = _hiveService.getSettings();
    _syncMustShowSecurityCode();
    notifyListeners();
  }

  /// Saves PIN/biometric, generates recovery code, unlocks session for code screen.
  Future<String> completeSecuritySetup({
    required String pinCode,
    required bool enableBiometric,
  }) async {
    final code = await _authService.completeSecuritySetup(
      pinCode: pinCode,
      biometricEnabled: enableBiometric,
    );
    _settings = _hiveService.getSettings();
    _isSessionUnlocked = true;
    _mustShowSecurityCode = true;
    _displaySecurityCode = code;
    // Do NOT notifyListeners here — triggers GoRouter redirect while
    // SetupLockScreen navigates and causes a permanent white screen.
    return code;
  }

  /// Called after user views and acknowledges the security recovery code.
  Future<void> acknowledgeSecurityCode() async {
    _mustShowSecurityCode = false;
    _displaySecurityCode = '';
    _settings = _settings.copyWith(securityCodeAcknowledged: true);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  bool validateLogin(String username, String password) {
    return _authService.validateLogin(username, password);
  }

  bool validatePin(String pin) {
    return _authService.validatePin(pin);
  }

  /// Resets password when the stored recovery security code matches.
  Future<bool> resetPassword({
    required String securityCode,
    required String newPassword,
  }) async {
    final ok = await _authService.resetPassword(
      securityCode: securityCode,
      newPassword: newPassword,
    );
    if (ok) {
      _settings = _hiveService.getSettings();
      notifyListeners();
    }
    return ok;
  }

  Future<bool> authenticateWithBiometric() async {
    if (!biometricEnabled) return false;
    final ok = await _biometricService.authenticate();
    if (ok) {
      _isSessionUnlocked = true;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> canUseBiometric() => _biometricService.canCheckBiometrics();

  /// Prompts biometric during initial setup (before it is saved as enabled).
  Future<bool> promptBiometricSetup() {
    return _biometricService.authenticate(
      reason: 'إعداد البصمة لتسجيل الدخول',
    );
  }

  void unlockSession() {
    _isSessionUnlocked = true;
    notifyListeners();
  }

  void lockSession() {
    if (!hasAccount || !isSecuritySetupComplete) return;
    if (needsSecurityCodeScreen) return;
    _isSessionUnlocked = false;
    notifyListeners();
  }

  void logout() {
    _isSessionUnlocked = false;
    notifyListeners();
  }
}
