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

  /// No description provided for @walletsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحافظ'**
  String get walletsTitle;

  /// No description provided for @walletsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة أصولك النقدية والبنكية'**
  String get walletsSubtitle;

  /// No description provided for @walletsAddWallet.
  ///
  /// In ar, this message translates to:
  /// **'إضافة محفظة'**
  String get walletsAddWallet;

  /// No description provided for @walletsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في المحافظ...'**
  String get walletsSearchHint;

  /// No description provided for @walletsEstimatedTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرصيد المقدر'**
  String get walletsEstimatedTotal;

  /// No description provided for @walletsMonthlyGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو شهري'**
  String get walletsMonthlyGrowth;

  /// No description provided for @walletsWalletCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المحافظ'**
  String get walletsWalletCount;

  /// No description provided for @walletsWalletCountValue.
  ///
  /// In ar, this message translates to:
  /// **'{count} محفظة'**
  String walletsWalletCountValue(int count);

  /// No description provided for @walletsTotalValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الكلية'**
  String get walletsTotalValue;

  /// No description provided for @walletsRemainingDebt.
  ///
  /// In ar, this message translates to:
  /// **'متبقي السداد'**
  String get walletsRemainingDebt;

  /// No description provided for @walletsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محافظ.\nأضف كاش، بنك، أو محفظة إلكترونية.'**
  String get walletsEmpty;

  /// No description provided for @walletsGrowthValue.
  ///
  /// In ar, this message translates to:
  /// **'+{percent}%'**
  String walletsGrowthValue(String percent);

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @walletFormTitleNew.
  ///
  /// In ar, this message translates to:
  /// **'محفظة جديدة'**
  String get walletFormTitleNew;

  /// No description provided for @walletFormTitleEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المحفظة'**
  String get walletFormTitleEdit;

  /// No description provided for @walletFormName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المحفظة'**
  String get walletFormName;

  /// No description provided for @walletFormNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: كاش، بنك'**
  String get walletFormNameHint;

  /// No description provided for @walletFormNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get walletFormNameRequired;

  /// No description provided for @walletFormCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get walletFormCurrency;

  /// No description provided for @walletFormSelectCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة'**
  String get walletFormSelectCurrency;

  /// No description provided for @walletFormOpeningBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الافتتاحي'**
  String get walletFormOpeningBalance;

  /// No description provided for @walletFormBalanceRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد مطلوب'**
  String get walletFormBalanceRequired;

  /// No description provided for @walletFormInvalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم غير صالح'**
  String get walletFormInvalidNumber;

  /// No description provided for @walletFormIcon.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get walletFormIcon;

  /// No description provided for @walletFormCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get walletFormCreate;

  /// No description provided for @walletFormSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get walletFormSave;

  /// No description provided for @walletFormDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المحفظة'**
  String get walletFormDeleteTitle;

  /// No description provided for @walletFormDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟ لا يمكن التراجع.'**
  String get walletFormDeleteMessage;

  /// No description provided for @walletFormError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String walletFormError(String error);

  /// No description provided for @treasuryIconCash.
  ///
  /// In ar, this message translates to:
  /// **'خزنة'**
  String get treasuryIconCash;

  /// No description provided for @treasuryIconCashShort.
  ///
  /// In ar, this message translates to:
  /// **'نقد'**
  String get treasuryIconCashShort;

  /// No description provided for @treasuryIconBank.
  ///
  /// In ar, this message translates to:
  /// **'بنك'**
  String get treasuryIconBank;

  /// No description provided for @treasuryIconCrypto.
  ///
  /// In ar, this message translates to:
  /// **'رقمية'**
  String get treasuryIconCrypto;

  /// No description provided for @treasuryIconTravel.
  ///
  /// In ar, this message translates to:
  /// **'سفر'**
  String get treasuryIconTravel;

  /// No description provided for @walletFormAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة محفظة'**
  String get walletFormAddTitle;

  /// No description provided for @walletFormAddSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف وعاءً مالياً جديداً لتنظيم ثروتك'**
  String get walletFormAddSubtitle;

  /// No description provided for @walletFormEditSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عدّل بيانات المحفظة'**
  String get walletFormEditSubtitle;

  /// No description provided for @walletFormWalletType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المحفظة'**
  String get walletFormWalletType;

  /// No description provided for @walletFormNameHintNew.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: مدخرات الطوارئ'**
  String get walletFormNameHintNew;

  /// No description provided for @walletFormAddOpeningBalance.
  ///
  /// In ar, this message translates to:
  /// **'إضافة رصيد افتتاحي'**
  String get walletFormAddOpeningBalance;

  /// No description provided for @walletFormConfirmAdd.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإضافة'**
  String get walletFormConfirmAdd;

  /// No description provided for @walletFormOpeningBalanceRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب إضافة رصيد افتتاحي لعملة واحدة على الأقل'**
  String get walletFormOpeningBalanceRequired;

  /// No description provided for @walletFormDuplicateCurrency.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تكرار العملة في نفس المحفظة'**
  String get walletFormDuplicateCurrency;

  /// No description provided for @walletsEditWallet.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المحفظة'**
  String get walletsEditWallet;

  /// No description provided for @walletFormCurrentBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get walletFormCurrentBalance;

  /// No description provided for @walletFormAccountHasTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف عملة مرتبطة بمعاملات أو تحويلات'**
  String get walletFormAccountHasTransactions;

  /// No description provided for @walletFormNoCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عملات. أضف عملة من الإعدادات أولاً.'**
  String get walletFormNoCurrencies;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'العملات'**
  String get settingsCurrencies;

  /// No description provided for @settingsBaseCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الرئيسية: {code}'**
  String settingsBaseCurrency(String code);

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsThemeSystem;

  /// No description provided for @settingsAppLock.
  ///
  /// In ar, this message translates to:
  /// **'قفل التطبيق'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب PIN أو البصمة للدخول مجدداً'**
  String get settingsAppLockSubtitle;

  /// No description provided for @settingsBackup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متاح في المرحلة 8'**
  String get settingsBackupSubtitle;

  /// No description provided for @currenciesTitle.
  ///
  /// In ar, this message translates to:
  /// **'العملات'**
  String get currenciesTitle;

  /// No description provided for @currencyDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف العملة'**
  String get currencyDeleteTitle;

  /// No description provided for @currencyDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'حذف {name} ({code})؟'**
  String currencyDeleteMessage(String name, String code);

  /// No description provided for @currencyExchangeRateBase.
  ///
  /// In ar, this message translates to:
  /// **'{code} — سعر الصرف: 1.0'**
  String currencyExchangeRateBase(String code);

  /// No description provided for @currencyFormEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العملة'**
  String get currencyFormEditTitle;

  /// No description provided for @currencyFormNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'عملة جديدة'**
  String get currencyFormNewTitle;

  /// No description provided for @currencyFormPresetHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر من القائمة أو أدخل يدوياً'**
  String get currencyFormPresetHint;

  /// No description provided for @currencyFormCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز العملة'**
  String get currencyFormCodeLabel;

  /// No description provided for @currencyFormCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'TRY'**
  String get currencyFormCodeHint;

  /// No description provided for @currencyFormInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز غير صالح'**
  String get currencyFormInvalidCode;

  /// No description provided for @currencyFormNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم العملة'**
  String get currencyFormNameLabel;

  /// No description provided for @currencyFormNameHint.
  ///
  /// In ar, this message translates to:
  /// **'ليرة تركية'**
  String get currencyFormNameHint;

  /// No description provided for @currencyFormSymbolLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرمز'**
  String get currencyFormSymbolLabel;

  /// No description provided for @currencyFormSymbolHint.
  ///
  /// In ar, this message translates to:
  /// **'₺'**
  String get currencyFormSymbolHint;

  /// No description provided for @currencyFormSymbolRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرمز مطلوب'**
  String get currencyFormSymbolRequired;

  /// No description provided for @currencyFormRateLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الصرف مقابل {baseCode}'**
  String currencyFormRateLabel(String baseCode);

  /// No description provided for @currencyFormRateHint.
  ///
  /// In ar, this message translates to:
  /// **'0.025'**
  String get currencyFormRateHint;

  /// No description provided for @currencyFormRateHelper.
  ///
  /// In ar, this message translates to:
  /// **'1 {code} = X {baseCode}'**
  String currencyFormRateHelper(String code, String baseCode);

  /// No description provided for @currencyFormRateRequired.
  ///
  /// In ar, this message translates to:
  /// **'سعر الصرف مطلوب'**
  String get currencyFormRateRequired;

  /// No description provided for @currencyFormPositiveNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقماً موجباً'**
  String get currencyFormPositiveNumber;

  /// No description provided for @currencyFormPreview.
  ///
  /// In ar, this message translates to:
  /// **'100 {code} {approx}'**
  String currencyFormPreview(String code, String approx);

  /// No description provided for @currencyFormAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get currencyFormAdd;

  /// No description provided for @currencyFormSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get currencyFormSave;

  /// No description provided for @dashboardRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get dashboardRetry;

  /// No description provided for @balanceHintZero.
  ///
  /// In ar, this message translates to:
  /// **'0.00'**
  String get balanceHintZero;

  /// No description provided for @onboardingContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get onboardingContinue;

  /// No description provided for @currencyBaseBadge.
  ///
  /// In ar, this message translates to:
  /// **'أساسية'**
  String get currencyBaseBadge;

  /// No description provided for @currencyBaseAlreadyExists.
  ///
  /// In ar, this message translates to:
  /// **'يوجد عملة أساسية بالفعل. لا يمكن إضافة أكثر من عملة أساسية واحدة.'**
  String get currencyBaseAlreadyExists;

  /// No description provided for @currencyAlreadyExists.
  ///
  /// In ar, this message translates to:
  /// **'العملة موجودة مسبقاً'**
  String get currencyAlreadyExists;

  /// No description provided for @currenciesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عملات.'**
  String get currenciesEmpty;
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
