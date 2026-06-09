import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'ديوان المال'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'مستقبلك المالي، بمعايير أخلاقية'**
  String get appTagline;

  /// No description provided for @routeError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح هذه الشاشة'**
  String get routeError;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get login;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، حاول مرة أخرى'**
  String get errorGeneric;

  /// No description provided for @errorGenericWithDetail.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {detail}'**
  String errorGenericWithDetail(String detail);

  /// No description provided for @authLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بياناتك للوصول إلى حسابك'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailOrPhone.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو الهاتف'**
  String get authEmailOrPhone;

  /// No description provided for @authEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'example@mail.com'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @authRememberDevice.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني على هذا الجهاز'**
  String get authRememberDevice;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول غير صحيحة'**
  String get authInvalidCredentials;

  /// No description provided for @authInvalidPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صالحة'**
  String get authInvalidPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ '**
  String get authNoAccount;

  /// No description provided for @authCreateAccountLink.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حساباً جديداً'**
  String get authCreateAccountLink;

  /// No description provided for @authRegisterTagline.
  ///
  /// In ar, this message translates to:
  /// **'ننمو معك بذكاء وأمان'**
  String get authRegisterTagline;

  /// No description provided for @authUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get authUsername;

  /// No description provided for @authUsernameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكامل'**
  String get authUsernameHint;

  /// No description provided for @authNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get authNameRequired;

  /// No description provided for @authPasswordShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً'**
  String get authPasswordShort;

  /// No description provided for @authConfirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authConfirmPassword;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get authPasswordMismatch;

  /// No description provided for @authTermsRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب الموافقة على الشروط والأحكام'**
  String get authTermsRequired;

  /// No description provided for @authTermsPrefix.
  ///
  /// In ar, this message translates to:
  /// **'بإنشاء حساب، أنت توافق على '**
  String get authTermsPrefix;

  /// No description provided for @authTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get authTerms;

  /// No description provided for @authTermsAnd.
  ///
  /// In ar, this message translates to:
  /// **' و '**
  String get authTermsAnd;

  /// No description provided for @authPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get authPrivacy;

  /// No description provided for @authCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get authCreateAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟ '**
  String get authHasAccount;

  /// No description provided for @authWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get authWelcome;

  /// No description provided for @authWelcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً'**
  String get authWelcomeBack;

  /// No description provided for @authStartNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'سجّل حساباً جديداً أو سجّل الدخول للمتابعة'**
  String get authStartNoAccount;

  /// No description provided for @authStartWithAccount.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد الهوية للمتابعة إلى حسابك في {appName}'**
  String authStartWithAccount(String appName);

  /// No description provided for @authStartBiometric.
  ///
  /// In ar, this message translates to:
  /// **'بدء المصادقة'**
  String get authStartBiometric;

  /// No description provided for @authUsePin.
  ///
  /// In ar, this message translates to:
  /// **'استخدام رمز PIN'**
  String get authUsePin;

  /// No description provided for @authUsePassword.
  ///
  /// In ar, this message translates to:
  /// **'استخدام كلمة المرور'**
  String get authUsePassword;

  /// No description provided for @authCreateAccountNew.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get authCreateAccountNew;

  /// No description provided for @authBankGradeSecurity.
  ///
  /// In ar, this message translates to:
  /// **'تشفير وحماية بمواصفات مصرفية'**
  String get authBankGradeSecurity;

  /// No description provided for @authCopyright.
  ///
  /// In ar, this message translates to:
  /// **'© ٢٠٢٤ ديوان المال للخدمات المالية. جميع الحقوق محفوظة.'**
  String get authCopyright;

  /// No description provided for @authBiometricFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التحقق بالبصمة، استخدم PIN'**
  String get authBiometricFailed;

  /// No description provided for @authUnlockSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN أو استخدم البصمة'**
  String get authUnlockSubtitle;

  /// No description provided for @authUseBiometric.
  ///
  /// In ar, this message translates to:
  /// **'استخدام البصمة'**
  String get authUseBiometric;

  /// No description provided for @authPinInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN غير صحيح'**
  String get authPinInvalid;

  /// No description provided for @authBiometricSetupFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت المصادقة البيومترية'**
  String get authBiometricSetupFailed;

  /// No description provided for @authFingerprint.
  ///
  /// In ar, this message translates to:
  /// **'بصمة الإصبع'**
  String get authFingerprint;

  /// No description provided for @authFingerprintDesc.
  ///
  /// In ar, this message translates to:
  /// **'استخدم المقاييس الحيوية لتسجيل الدخول الفوري والمؤمّن'**
  String get authFingerprintDesc;

  /// No description provided for @authSetupFingerprint.
  ///
  /// In ar, this message translates to:
  /// **'إعداد البصمة'**
  String get authSetupFingerprint;

  /// No description provided for @authFingerprintDone.
  ///
  /// In ar, this message translates to:
  /// **'تم إعداد البصمة ✓'**
  String get authFingerprintDone;

  /// No description provided for @authFingerprintSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إعداد البصمة بنجاح'**
  String get authFingerprintSuccess;

  /// No description provided for @authFingerprintError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إعداد البصمة'**
  String get authFingerprintError;

  /// No description provided for @authPinPersonal.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN الشخصي'**
  String get authPinPersonal;

  /// No description provided for @authPinReenter.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال رمز PIN'**
  String get authPinReenter;

  /// No description provided for @authPinConfirmHint.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز للمتابعة'**
  String get authPinConfirmHint;

  /// No description provided for @authPinEnterHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل 4 أرقام لتأمين عملياتك المالية'**
  String get authPinEnterHint;

  /// No description provided for @authPinMinDigits.
  ///
  /// In ar, this message translates to:
  /// **'أدخل 4 أرقام'**
  String get authPinMinDigits;

  /// No description provided for @authPinMismatch.
  ///
  /// In ar, this message translates to:
  /// **'رمز PIN غير متطابق'**
  String get authPinMismatch;

  /// No description provided for @authSavePin.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الرمز'**
  String get authSavePin;

  /// No description provided for @authSecurityCodeFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء رمز الأمان'**
  String get authSecurityCodeFailed;

  /// No description provided for @authAccountCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب بنجاح!'**
  String get authAccountCreated;

  /// No description provided for @authSecurityCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'احفظ رمز الأمان هذا لاستخدامه في استعادة كلمة المرور في حال فقدانها.'**
  String get authSecurityCodeHint;

  /// No description provided for @authSecurityCodeLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل رمز الأمان. أعد تشغيل التطبيق أو سجّل حساباً جديداً.'**
  String get authSecurityCodeLoadError;

  /// No description provided for @authYourSecurityCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الأمان الخاص بك'**
  String get authYourSecurityCode;

  /// No description provided for @authCopyCode.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرمز'**
  String get authCopyCode;

  /// No description provided for @authCodeCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرمز'**
  String get authCodeCopied;

  /// No description provided for @authSecurityWarning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير: لا تشارك هذا الرمز مع أي شخص. موظفو ديوان المال لن يطلبوا منك هذا الرمز أبداً.'**
  String get authSecurityWarning;

  /// No description provided for @authGoToCurrency.
  ///
  /// In ar, this message translates to:
  /// **'سيتم توجيهك لاختيار العملة الرئيسية'**
  String get authGoToCurrency;

  /// No description provided for @authResetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get authResetPassword;

  /// No description provided for @authResetPasswordDesc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز الأمان الذي حفظته عند التسجيل وكلمة المرور الجديدة لتأمين حسابك.'**
  String get authResetPasswordDesc;

  /// No description provided for @authSecurityCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الأمان'**
  String get authSecurityCode;

  /// No description provided for @authSecurityCodeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز الأمان (6 أحرف)'**
  String get authSecurityCodeInvalid;

  /// No description provided for @authNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get authNewPassword;

  /// No description provided for @authNewPasswordShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة (6 أحرف على الأقل)'**
  String get authNewPasswordShort;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get authConfirmNewPassword;

  /// No description provided for @authNoLocalAccount.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد حساب مسجّل على هذا الجهاز.'**
  String get authNoLocalAccount;

  /// No description provided for @authNoAccountOnDevice.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد حساب على هذا الجهاز'**
  String get authNoAccountOnDevice;

  /// No description provided for @authWrongSecurityCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الأمان غير صحيح'**
  String get authWrongSecurityCode;

  /// No description provided for @authPasswordChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get authPasswordChanged;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات'**
  String get navTransactions;

  /// No description provided for @navWallets.
  ///
  /// In ar, this message translates to:
  /// **'المحافظ'**
  String get navWallets;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @dashboardMyCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'عملاتي وأرصدة'**
  String get dashboardMyCurrencies;

  /// No description provided for @dashboardNoCurrencyBalances.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أرصدة في المحافظ بعد'**
  String get dashboardNoCurrencyBalances;

  /// No description provided for @dashboardTotalBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الإجمالي ({code})'**
  String dashboardTotalBalance(String code);

  /// No description provided for @dashboardApproxBase.
  ///
  /// In ar, this message translates to:
  /// **'≈ {amount}'**
  String dashboardApproxBase(String amount);

  /// No description provided for @dashboardMonthlyIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل الشهر'**
  String get dashboardMonthlyIncome;

  /// No description provided for @dashboardMonthlyExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف الشهر'**
  String get dashboardMonthlyExpense;

  /// No description provided for @dashboardDebts.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get dashboardDebts;

  /// No description provided for @dashboardDebtsOwedToOthers.
  ///
  /// In ar, this message translates to:
  /// **'علي للآخرين'**
  String get dashboardDebtsOwedToOthers;

  /// No description provided for @dashboardIncomeChange.
  ///
  /// In ar, this message translates to:
  /// **'+{percent}% ↑'**
  String dashboardIncomeChange(int percent);

  /// No description provided for @dashboardExpenseChange.
  ///
  /// In ar, this message translates to:
  /// **'-{percent}% ↓'**
  String dashboardExpenseChange(int percent);

  /// No description provided for @dashboardFinancialGoals.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف المالية'**
  String get dashboardFinancialGoals;

  /// No description provided for @dashboardAddGoal.
  ///
  /// In ar, this message translates to:
  /// **'إضافة هدف'**
  String get dashboardAddGoal;

  /// No description provided for @dashboardExpenseAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المصروفات'**
  String get dashboardExpenseAnalysis;

  /// No description provided for @dashboardLast30Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 30 يوم'**
  String get dashboardLast30Days;

  /// No description provided for @dashboardDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get dashboardDaily;

  /// No description provided for @dashboardWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get dashboardWeekly;

  /// No description provided for @dashboardRecentTransactions.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات الأخيرة'**
  String get dashboardRecentTransactions;

  /// No description provided for @dashboardMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get dashboardMore;

  /// No description provided for @dashboardToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get dashboardToday;

  /// No description provided for @dashboardYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get dashboardYesterday;

  /// No description provided for @dashboardGoalBuyCar.
  ///
  /// In ar, this message translates to:
  /// **'شراء سيارة'**
  String get dashboardGoalBuyCar;

  /// No description provided for @dashboardTxGroceryTitle.
  ///
  /// In ar, this message translates to:
  /// **'بقالة المجد'**
  String get dashboardTxGroceryTitle;

  /// No description provided for @dashboardTxGroceryTime.
  ///
  /// In ar, this message translates to:
  /// **'اليوم، 10:30 ص'**
  String get dashboardTxGroceryTime;

  /// No description provided for @dashboardTxSalaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'راتب الشهر'**
  String get dashboardTxSalaryTitle;

  /// No description provided for @dashboardTxSalaryTime.
  ///
  /// In ar, this message translates to:
  /// **'أمس، 09:00 ص'**
  String get dashboardTxSalaryTime;

  /// No description provided for @dashboardChartMay1.
  ///
  /// In ar, this message translates to:
  /// **'1 مايو'**
  String get dashboardChartMay1;

  /// No description provided for @dashboardChartMay10.
  ///
  /// In ar, this message translates to:
  /// **'10 مايو'**
  String get dashboardChartMay10;

  /// No description provided for @dashboardChartMay20.
  ///
  /// In ar, this message translates to:
  /// **'20 مايو'**
  String get dashboardChartMay20;

  /// No description provided for @dashboardChartMay30.
  ///
  /// In ar, this message translates to:
  /// **'30 مايو'**
  String get dashboardChartMay30;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @profileComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'صفحة الملف الشخصي قيد التطوير'**
  String get profileComingSoon;

  /// No description provided for @transactionAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة معاملة'**
  String get transactionAddTitle;

  /// No description provided for @transactionAddComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'إضافة المعاملات ستتوفر قريباً'**
  String get transactionAddComingSoon;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
