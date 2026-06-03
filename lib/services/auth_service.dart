import 'dart:math';

import '../models/app_settings.dart';
import 'hive_service.dart';

/// Local authentication helpers (offline account).
class AuthService {
  AuthService(this._hiveService);

  final HiveService _hiveService;
  final _random = Random.secure();

  /// Generates a 6-character security code like B7M4X9.
  String generateSecurityCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  AppSettings get _settings => _hiveService.getSettings();

  Future<void> register({
    required String username,
    required String password,
    required String securityCode,
  }) async {
    final updated = _settings.copyWith(
      hasAccount: true,
      username: username.trim(),
      password: password,
      securityCode: securityCode,
      isSecuritySetupComplete: false,
      pinCode: '',
      biometricEnabled: false,
    );
    await _hiveService.saveSettings(updated);
  }

  /// Saves PIN/biometric and assigns a new random recovery security code.
  Future<String> completeSecuritySetup({
    required String pinCode,
    required bool biometricEnabled,
  }) async {
    final securityCode = generateSecurityCode();
    final updated = _settings.copyWith(
      pinCode: pinCode,
      biometricEnabled: biometricEnabled,
      isSecuritySetupComplete: true,
      securityCode: securityCode,
      securityCodeAcknowledged: false,
    );
    await _hiveService.saveSettings(updated);
    return securityCode;
  }

  bool validateLogin(String username, String password) {
    if (!_settings.hasAccount) return false;
    return _settings.username == username.trim() && _settings.password == password;
  }

  bool validatePin(String pin) {
    return _settings.pinCode.isNotEmpty && _settings.pinCode == pin;
  }

  bool get hasAccount => _settings.hasAccount;
  bool get isSecuritySetupComplete => _settings.isSecuritySetupComplete;
  bool get biometricEnabled => _settings.biometricEnabled;
  String get securityCode => _settings.securityCode;
}
