import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

/// Wraps device biometric authentication.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  static const _authMessages = <AuthMessages>[
    AndroidAuthMessages(
      signInTitle: 'المصادقة البيومترية',
      biometricHint: 'المس مستشعر البصمة',
      biometricNotRecognized: 'لم يتم التعرف على البصمة، حاول مجدداً',
      biometricRequiredTitle: 'البصمة مطلوبة',
      biometricSuccess: 'تم التحقق بنجاح',
      cancelButton: 'إلغاء',
      deviceCredentialsRequiredTitle: 'مطلوب قفل الجهاز',
      deviceCredentialsSetupDescription:
          'يرجى إعداد قفل الشاشة على جهازك لاستخدام البصمة',
      goToSettingsButton: 'الذهاب إلى الإعدادات',
      goToSettingsDescription:
          'لم يتم إعداد البصمة على جهازك. يرجى إعدادها من إعدادات الجهاز.',
    ),
    IOSAuthMessages(
      cancelButton: 'إلغاء',
      goToSettingsButton: 'الإعدادات',
      goToSettingsDescription:
          'لم يتم إعداد البصمة على جهازك. يرجى إعدادها من إعدادات الجهاز.',
      lockOut: 'تم قفل المصادقة البيومترية. أعد المحاولة لاحقاً.',
    ),
  ];

  /// Returns whether the device supports biometric authentication.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e, stack) {
      debugPrint('BiometricService.canCheckBiometrics: $e\n$stack');
      return false;
    }
  }

  /// Prompts the user for biometric verification.
  Future<bool> authenticate({String reason = 'تأكيد الهوية للدخول'}) async {
    try {
      if (!await _auth.isDeviceSupported()) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
        authMessages: _authMessages,
      );
    } on PlatformException catch (e, stack) {
      debugPrint(
        'BiometricService.authenticate: ${e.code} ${e.message}\n$stack',
      );
      return false;
    } catch (e, stack) {
      debugPrint('BiometricService.authenticate: $e\n$stack');
      return false;
    }
  }
}
