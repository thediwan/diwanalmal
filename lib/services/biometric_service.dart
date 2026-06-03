import 'package:local_auth/local_auth.dart';

/// Wraps device biometric authentication.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns whether biometric hardware is available.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user for biometric verification.
  Future<bool> authenticate({String reason = 'تأكيد الهوية للدخول'}) async {
    try {
      final canUse = await canCheckBiometrics();
      if (!canUse) return false;

      return await _auth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }
}
