// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ديوان المال';

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
      '© ٢٠٢٤ ديوان المال للخدمات المالية. جميع الحقوق محفوظة.';

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
      'تحذير: لا تشارك هذا الرمز مع أي شخص. موظفو ديوان المال لن يطلبوا منك هذا الرمز أبداً.';

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
  String get navTransactions => 'المعاملات';

  @override
  String get navWallets => 'المحافظ';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get dashboardMyCurrencies => 'عملاتي وأرصدة';

  @override
  String get dashboardNoCurrencyBalances => 'لا توجد أرصدة في المحافظ بعد';

  @override
  String dashboardTotalBalance(String code) {
    return 'الرصيد الإجمالي ($code)';
  }

  @override
  String dashboardApproxBase(String amount) {
    return '≈ $amount';
  }

  @override
  String get dashboardMonthlyIncome => 'دخل الشهر';

  @override
  String get dashboardMonthlyExpense => 'مصروف الشهر';

  @override
  String get dashboardDebts => 'الديون';

  @override
  String get dashboardDebtsOwedToOthers => 'علي للآخرين';

  @override
  String dashboardIncomeChange(int percent) {
    return '+$percent% ↑';
  }

  @override
  String dashboardExpenseChange(int percent) {
    return '-$percent% ↓';
  }

  @override
  String get dashboardFinancialGoals => 'الأهداف المالية';

  @override
  String get dashboardAddGoal => 'إضافة هدف';

  @override
  String get dashboardExpenseAnalysis => 'تحليل المصروفات';

  @override
  String get dashboardLast30Days => 'آخر 30 يوم';

  @override
  String get dashboardDaily => 'يومي';

  @override
  String get dashboardWeekly => 'أسبوعي';

  @override
  String get dashboardRecentTransactions => 'المعاملات الأخيرة';

  @override
  String get dashboardMore => 'المزيد';

  @override
  String get dashboardToday => 'اليوم';

  @override
  String get dashboardYesterday => 'أمس';

  @override
  String get dashboardGoalBuyCar => 'شراء سيارة';

  @override
  String get dashboardTxGroceryTitle => 'بقالة المجد';

  @override
  String get dashboardTxGroceryTime => 'اليوم، 10:30 ص';

  @override
  String get dashboardTxSalaryTitle => 'راتب الشهر';

  @override
  String get dashboardTxSalaryTime => 'أمس، 09:00 ص';

  @override
  String get dashboardChartMay1 => '1 مايو';

  @override
  String get dashboardChartMay10 => '10 مايو';

  @override
  String get dashboardChartMay20 => '20 مايو';

  @override
  String get dashboardChartMay30 => '30 مايو';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileComingSoon => 'صفحة الملف الشخصي قيد التطوير';

  @override
  String get transactionAddTitle => 'إضافة معاملة';

  @override
  String get transactionAddComingSoon => 'إضافة المعاملات ستتوفر قريباً';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get walletsTitle => 'المحافظ';

  @override
  String get walletsSubtitle => 'إدارة أصولك النقدية والبنكية';

  @override
  String get walletsAddWallet => 'إضافة محفظة';

  @override
  String get walletsSearchHint => 'بحث في المحافظ...';

  @override
  String get walletsEstimatedTotal => 'إجمالي الرصيد المقدر';

  @override
  String get walletsMonthlyGrowth => 'نمو شهري';

  @override
  String get walletsWalletCount => 'عدد المحافظ';

  @override
  String walletsWalletCountValue(int count) {
    return '$count محفظة';
  }

  @override
  String get walletsTotalValue => 'القيمة الكلية';

  @override
  String get walletsRemainingDebt => 'متبقي السداد';

  @override
  String get walletsEmpty =>
      'لا توجد محافظ.\nأضف كاش، بنك، أو محفظة إلكترونية.';

  @override
  String walletsGrowthValue(String percent) {
    return '+$percent%';
  }

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get walletFormTitleNew => 'محفظة جديدة';

  @override
  String get walletFormTitleEdit => 'تعديل المحفظة';

  @override
  String get walletFormName => 'اسم المحفظة';

  @override
  String get walletFormNameHint => 'مثال: كاش، بنك';

  @override
  String get walletFormNameRequired => 'الاسم مطلوب';

  @override
  String get walletFormCurrency => 'العملة';

  @override
  String get walletFormSelectCurrency => 'اختر العملة';

  @override
  String get walletFormOpeningBalance => 'الرصيد الافتتاحي';

  @override
  String get walletFormBalanceRequired => 'الرصيد مطلوب';

  @override
  String get walletFormInvalidNumber => 'رقم غير صالح';

  @override
  String get walletFormIcon => 'الأيقونة';

  @override
  String get walletFormCreate => 'إنشاء';

  @override
  String get walletFormSave => 'حفظ';

  @override
  String get walletFormDeleteTitle => 'حذف المحفظة';

  @override
  String get walletFormDeleteMessage => 'هل أنت متأكد؟ لا يمكن التراجع.';

  @override
  String walletFormError(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get treasuryIconCash => 'خزنة';

  @override
  String get treasuryIconCashShort => 'نقد';

  @override
  String get treasuryIconBank => 'بنك';

  @override
  String get treasuryIconCrypto => 'رقمية';

  @override
  String get treasuryIconTravel => 'سفر';

  @override
  String get walletFormAddTitle => 'إضافة محفظة';

  @override
  String get walletFormAddSubtitle => 'أضف وعاءً مالياً جديداً لتنظيم ثروتك';

  @override
  String get walletFormEditSubtitle => 'عدّل بيانات المحفظة';

  @override
  String get walletFormWalletType => 'نوع المحفظة';

  @override
  String get walletFormNameHintNew => 'مثلاً: مدخرات الطوارئ';

  @override
  String get walletFormAddOpeningBalance => 'إضافة رصيد افتتاحي';

  @override
  String get walletFormConfirmAdd => 'تأكيد الإضافة';

  @override
  String get walletFormOpeningBalanceRequired =>
      'يجب إضافة رصيد افتتاحي لعملة واحدة على الأقل';

  @override
  String get walletFormDuplicateCurrency =>
      'لا يمكن تكرار العملة في نفس المحفظة';

  @override
  String get walletsEditWallet => 'تعديل المحفظة';

  @override
  String get walletFormCurrentBalance => 'الرصيد الحالي';

  @override
  String get walletFormAccountHasTransactions =>
      'لا يمكن حذف عملة مرتبطة بمعاملات أو تحويلات';

  @override
  String get walletFormNoCurrencies =>
      'لا توجد عملات. أضف عملة من الإعدادات أولاً.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsCurrencies => 'العملات';

  @override
  String settingsBaseCurrency(String code) {
    return 'العملة الرئيسية: $code';
  }

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'تلقائي';

  @override
  String get settingsAppLock => 'قفل التطبيق';

  @override
  String get settingsAppLockSubtitle => 'يتطلب PIN أو البصمة للدخول مجدداً';

  @override
  String get settingsBackup => 'النسخ الاحتياطي';

  @override
  String get settingsBackupSubtitle => 'متاح في المرحلة 8';

  @override
  String get currenciesTitle => 'العملات';

  @override
  String get currencyDeleteTitle => 'حذف العملة';

  @override
  String currencyDeleteMessage(String name, String code) {
    return 'حذف $name ($code)؟';
  }

  @override
  String currencyExchangeRateBase(String code) {
    return '$code — سعر الصرف: 1.0';
  }

  @override
  String get currencyFormEditTitle => 'تعديل العملة';

  @override
  String get currencyFormNewTitle => 'عملة جديدة';

  @override
  String get currencyFormPresetHint => 'اختر من القائمة أو أدخل يدوياً';

  @override
  String get currencyFormCodeLabel => 'رمز العملة';

  @override
  String get currencyFormCodeHint => 'TRY';

  @override
  String get currencyFormInvalidCode => 'رمز غير صالح';

  @override
  String get currencyFormNameLabel => 'اسم العملة';

  @override
  String get currencyFormNameHint => 'ليرة تركية';

  @override
  String get currencyFormSymbolLabel => 'الرمز';

  @override
  String get currencyFormSymbolHint => '₺';

  @override
  String get currencyFormSymbolRequired => 'الرمز مطلوب';

  @override
  String currencyFormRateLabel(String baseCode) {
    return 'سعر الصرف مقابل $baseCode';
  }

  @override
  String get currencyFormRateHint => '0.025';

  @override
  String currencyFormRateHelper(String code, String baseCode) {
    return '1 $code = X $baseCode';
  }

  @override
  String get currencyFormRateRequired => 'سعر الصرف مطلوب';

  @override
  String get currencyFormPositiveNumber => 'أدخل رقماً موجباً';

  @override
  String currencyFormPreview(String code, String approx) {
    return '100 $code $approx';
  }

  @override
  String get currencyFormAdd => 'إضافة';

  @override
  String get currencyFormSave => 'حفظ';

  @override
  String get dashboardRetry => 'إعادة المحاولة';

  @override
  String get balanceHintZero => '0.00';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get currencyBaseBadge => 'أساسية';

  @override
  String get currencyBaseAlreadyExists =>
      'يوجد عملة أساسية بالفعل. لا يمكن إضافة أكثر من عملة أساسية واحدة.';

  @override
  String get currencyAlreadyExists => 'العملة موجودة مسبقاً';

  @override
  String get currenciesEmpty => 'لا توجد عملات.';
}
