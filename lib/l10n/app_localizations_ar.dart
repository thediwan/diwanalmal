// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بيت المال';

  @override
  String get appTagline => 'مستقبلك المالي، بمعايير أخلاقية';

  @override
  String get routeError => 'تعذر فتح هذه الشاشة';

  @override
  String get ok => 'حسناً';

  @override
  String get next => 'التالي';

  @override
  String get login => 'دخول';

  @override
  String get fieldRequired => 'الحقل مطلوب';

  @override
  String get errorGeneric => 'حدث خطأ، حاول مرة أخرى';

  @override
  String errorGenericWithDetail(String detail) {
    return 'حدث خطأ: $detail';
  }

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authLoginSubtitle => 'أدخل بياناتك للوصول إلى حسابك';

  @override
  String get authEmailOrPhone => 'البريد الإلكتروني أو الهاتف';

  @override
  String get authEmailHint => 'example@mail.com';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authRememberDevice => 'تذكرني على هذا الجهاز';

  @override
  String get authInvalidCredentials => 'بيانات الدخول غير صحيحة';

  @override
  String get authInvalidPassword => 'كلمة المرور غير صالحة';

  @override
  String get authNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get authCreateAccountLink => 'أنشئ حساباً جديداً';

  @override
  String get authRegisterTagline => 'ننمو معك بذكاء وأمان';

  @override
  String get authUsername => 'اسم المستخدم';

  @override
  String get authUsernameHint => 'أدخل اسمك الكامل';

  @override
  String get authNameRequired => 'الاسم مطلوب';

  @override
  String get authPasswordShort => 'كلمة المرور قصيرة جداً';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authTermsRequired => 'يجب الموافقة على الشروط والأحكام';

  @override
  String get authTermsPrefix => 'بإنشاء حساب، أنت توافق على ';

  @override
  String get authTerms => 'الشروط والأحكام';

  @override
  String get authTermsAnd => ' و ';

  @override
  String get authPrivacy => 'سياسة الخصوصية';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authHasAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get authWelcome => 'مرحباً بك';

  @override
  String get authWelcomeBack => 'مرحباً بك مجدداً';

  @override
  String get authStartNoAccount => 'سجّل حساباً جديداً أو سجّل الدخول للمتابعة';

  @override
  String authStartWithAccount(String appName) {
    return 'يرجى تأكيد الهوية للمتابعة إلى حسابك في $appName';
  }

  @override
  String get authStartBiometric => 'بدء المصادقة';

  @override
  String get authUsePin => 'استخدام رمز PIN';

  @override
  String get authUsePassword => 'استخدام كلمة المرور';

  @override
  String get authCreateAccountNew => 'إنشاء حساب جديد';

  @override
  String get authBankGradeSecurity => 'تشفير وحماية بمواصفات مصرفية';

  @override
  String get authCopyright =>
      '© ٢٠٢٤ بيت المال للخدمات المالية. جميع الحقوق محفوظة.';

  @override
  String get authBiometricFailed => 'تعذر التحقق بالبصمة، استخدم PIN';

  @override
  String get authUnlockSubtitle => 'أدخل رمز PIN أو استخدم البصمة';

  @override
  String get authUseBiometric => 'استخدام البصمة';

  @override
  String get authPinInvalid => 'رمز PIN غير صحيح';

  @override
  String get authBiometricSetupFailed => 'فشلت المصادقة البيومترية';

  @override
  String get authFingerprint => 'بصمة الإصبع';

  @override
  String get authFingerprintDesc =>
      'استخدم المقاييس الحيوية لتسجيل الدخول الفوري والمؤمّن';

  @override
  String get authSetupFingerprint => 'إعداد البصمة';

  @override
  String get authFingerprintDone => 'تم إعداد البصمة ✓';

  @override
  String get authFingerprintSuccess => 'تم إعداد البصمة بنجاح';

  @override
  String get authFingerprintError => 'تعذر إعداد البصمة';

  @override
  String get authPinPersonal => 'رمز PIN الشخصي';

  @override
  String get authPinReenter => 'أعد إدخال رمز PIN';

  @override
  String get authPinConfirmHint => 'تأكيد الرمز للمتابعة';

  @override
  String get authPinEnterHint => 'أدخل 4 أرقام لتأمين عملياتك المالية';

  @override
  String get authPinMinDigits => 'أدخل 4 أرقام';

  @override
  String get authPinMismatch => 'رمز PIN غير متطابق';

  @override
  String get authSavePin => 'حفظ الرمز';

  @override
  String get authSecurityCodeFailed => 'تعذر إنشاء رمز الأمان';

  @override
  String get authAccountCreated => 'تم إنشاء الحساب بنجاح!';

  @override
  String get authSecurityCodeHint =>
      'احفظ رمز الأمان هذا لاستخدامه في استعادة كلمة المرور في حال فقدانها.';

  @override
  String get authSecurityCodeLoadError =>
      'تعذر تحميل رمز الأمان. أعد تشغيل التطبيق أو سجّل حساباً جديداً.';

  @override
  String get authYourSecurityCode => 'رمز الأمان الخاص بك';

  @override
  String get authCopyCode => 'نسخ الرمز';

  @override
  String get authCodeCopied => 'تم نسخ الرمز';

  @override
  String get authSecurityWarning =>
      'تحذير: لا تشارك هذا الرمز مع أي شخص. موظفو بيت المال لن يطلبوا منك هذا الرمز أبداً.';

  @override
  String get authGoToCurrency => 'سيتم توجيهك لاختيار العملة الرئيسية';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordDesc =>
      'أدخل رمز الأمان الذي حفظته عند التسجيل وكلمة المرور الجديدة لتأمين حسابك.';

  @override
  String get authSecurityCode => 'رمز الأمان';

  @override
  String get authSecurityCodeInvalid => 'أدخل رمز الأمان (6 أحرف)';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authNewPasswordShort => 'كلمة المرور قصيرة (6 أحرف على الأقل)';

  @override
  String get authConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get authNoLocalAccount => 'لا يوجد حساب مسجّل على هذا الجهاز.';

  @override
  String get authNoAccountOnDevice => 'لا يوجد حساب على هذا الجهاز';

  @override
  String get authWrongSecurityCode => 'رمز الأمان غير صحيح';

  @override
  String get authPasswordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navWallets => 'المحافظ';

  @override
  String get navSettings => 'الإعدادات';
}
