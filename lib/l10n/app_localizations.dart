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

  /// No description provided for @feedbackDatabaseError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في قاعدة البيانات. أعد تشغيل التطبيق بالكامل.'**
  String get feedbackDatabaseError;

  /// No description provided for @walletFormSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المحفظة بنجاح'**
  String get walletFormSaveSuccess;

  /// No description provided for @walletFormDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المحفظة بنجاح'**
  String get walletFormDeleteSuccess;

  /// No description provided for @currencyFormSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ العملة بنجاح'**
  String get currencyFormSaveSuccess;

  /// No description provided for @currencyDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العملة بنجاح'**
  String get currencyDeleteSuccess;

  /// No description provided for @goalPlanSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الهدف بنجاح'**
  String get goalPlanSaveSuccess;

  /// No description provided for @goalEditSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الهدف بنجاح'**
  String get goalEditSaveSuccess;

  /// No description provided for @goalEditDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الهدف بنجاح'**
  String get goalEditDeleteSuccess;

  /// No description provided for @onboardingBaseCurrencySuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تعيين العملة الأساسية بنجاح'**
  String get onboardingBaseCurrencySuccess;

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

  /// No description provided for @dashboardBalanceCardType.
  ///
  /// In ar, this message translates to:
  /// **'محفظة رقمية'**
  String get dashboardBalanceCardType;

  /// No description provided for @dashboardBalanceCardHolder.
  ///
  /// In ar, this message translates to:
  /// **'الحامل'**
  String get dashboardBalanceCardHolder;

  /// No description provided for @dashboardBalanceCardExpDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الصلاحية'**
  String get dashboardBalanceCardExpDate;

  /// No description provided for @dashboardCardMenuTitle.
  ///
  /// In ar, this message translates to:
  /// **'خيارات البطاقة'**
  String get dashboardCardMenuTitle;

  /// No description provided for @dashboardCardMenuViewWallets.
  ///
  /// In ar, this message translates to:
  /// **'عرض المحافظ'**
  String get dashboardCardMenuViewWallets;

  /// No description provided for @dashboardCardMenuAddTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة معاملة'**
  String get dashboardCardMenuAddTransaction;

  /// No description provided for @dashboardCardMenuTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get dashboardCardMenuTransfer;

  /// No description provided for @dashboardCardMenuViewStats.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get dashboardCardMenuViewStats;

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

  /// No description provided for @dashboardLast7Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 7 أيام'**
  String get dashboardLast7Days;

  /// No description provided for @dashboardLast4Weeks.
  ///
  /// In ar, this message translates to:
  /// **'آخر 4 أسابيع'**
  String get dashboardLast4Weeks;

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

  /// No description provided for @dashboardChartMin.
  ///
  /// In ar, this message translates to:
  /// **'الأقل'**
  String get dashboardChartMin;

  /// No description provided for @dashboardChartMax.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى'**
  String get dashboardChartMax;

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

  /// No description provided for @transactionFormExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get transactionFormExpense;

  /// No description provided for @transactionFormIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get transactionFormIncome;

  /// No description provided for @transactionFormCurrencyTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بين عملات'**
  String get transactionFormCurrencyTransfer;

  /// No description provided for @transactionFormDebtor.
  ///
  /// In ar, this message translates to:
  /// **'مدين (لي عليه)'**
  String get transactionFormDebtor;

  /// No description provided for @transactionFormCreditor.
  ///
  /// In ar, this message translates to:
  /// **'دائن (علي)'**
  String get transactionFormCreditor;

  /// No description provided for @transactionFormPersonName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشخص'**
  String get transactionFormPersonName;

  /// No description provided for @transactionFormPersonNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الشخص'**
  String get transactionFormPersonNameHint;

  /// No description provided for @transactionFormPersonNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الشخص'**
  String get transactionFormPersonNameRequired;

  /// No description provided for @transactionFormDueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get transactionFormDueDate;

  /// No description provided for @transactionFormDueDateOptional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري — اضغط للتحديد'**
  String get transactionFormDueDateOptional;

  /// No description provided for @transactionFormClearDueDate.
  ///
  /// In ar, this message translates to:
  /// **'مسح تاريخ الاستحقاق'**
  String get transactionFormClearDueDate;

  /// No description provided for @transactionFormDebtLedgerHint.
  ///
  /// In ar, this message translates to:
  /// **'قيد الذمة لا يؤثر على رصيد المحفظة حتى الدفع أو التحصيل.'**
  String get transactionFormDebtLedgerHint;

  /// No description provided for @transactionFormDebtSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ قيد الذمة بنجاح'**
  String get transactionFormDebtSaveSuccess;

  /// No description provided for @transactionDebtTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get transactionDebtTotal;

  /// No description provided for @transactionDebtPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get transactionDebtPaid;

  /// No description provided for @transactionDebtRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get transactionDebtRemaining;

  /// No description provided for @transactionDebtPaymentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدفعات'**
  String get transactionDebtPaymentHistory;

  /// No description provided for @transactionDebtNoPayments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دفعات بعد'**
  String get transactionDebtNoPayments;

  /// No description provided for @transactionDebtReceive.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل'**
  String get transactionDebtReceive;

  /// No description provided for @transactionDebtPay.
  ///
  /// In ar, this message translates to:
  /// **'دفع'**
  String get transactionDebtPay;

  /// No description provided for @transactionDebtSettleTitle.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التسديد'**
  String get transactionDebtSettleTitle;

  /// No description provided for @transactionDebtSettleHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ للدفع أو التحصيل'**
  String get transactionDebtSettleHint;

  /// No description provided for @transactionDebtSettleConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get transactionDebtSettleConfirm;

  /// No description provided for @transactionDebtSettleSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة بنجاح'**
  String get transactionDebtSettleSuccess;

  /// No description provided for @transactionDebtSettleExceedsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أكبر من المتبقي'**
  String get transactionDebtSettleExceedsRemaining;

  /// No description provided for @transactionDebtFullyPaid.
  ///
  /// In ar, this message translates to:
  /// **'مسدّد بالكامل'**
  String get transactionDebtFullyPaid;

  /// No description provided for @transactionDebtSettlementTitleReceive.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل — {person}'**
  String transactionDebtSettlementTitleReceive(String person);

  /// No description provided for @transactionDebtSettlementTitlePay.
  ///
  /// In ar, this message translates to:
  /// **'دفع — {person}'**
  String transactionDebtSettlementTitlePay(String person);

  /// No description provided for @transactionFormSourceCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة المصدر'**
  String get transactionFormSourceCurrency;

  /// No description provided for @transactionFormTargetCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الهدف'**
  String get transactionFormTargetCurrency;

  /// No description provided for @transactionFormSourceWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة المصدر'**
  String get transactionFormSourceWallet;

  /// No description provided for @transactionFormTargetWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة الهدف'**
  String get transactionFormTargetWallet;

  /// No description provided for @transactionFormConvertedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المحوّل: {amount}'**
  String transactionFormConvertedAmount(String amount);

  /// No description provided for @transactionFormTransferSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التحويل بنجاح'**
  String get transactionFormTransferSaveSuccess;

  /// No description provided for @transactionFormSelectSourceCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة المصدر'**
  String get transactionFormSelectSourceCurrency;

  /// No description provided for @transactionFormSelectTargetCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة الهدف'**
  String get transactionFormSelectTargetCurrency;

  /// No description provided for @transactionFormSelectSourceWallet.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحفظة المصدر'**
  String get transactionFormSelectSourceWallet;

  /// No description provided for @transactionFormSelectTargetWallet.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحفظة الهدف'**
  String get transactionFormSelectTargetWallet;

  /// No description provided for @transactionFormTransferSameError.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تختلف العملة أو المحفظة بين المصدر والهدف'**
  String get transactionFormTransferSameError;

  /// No description provided for @transactionFormExchangeRate.
  ///
  /// In ar, this message translates to:
  /// **'سعر الصرف'**
  String get transactionFormExchangeRate;

  /// No description provided for @transactionFormExchangeRateHint.
  ///
  /// In ar, this message translates to:
  /// **'1 {source} = ? {target}'**
  String transactionFormExchangeRateHint(String source, String target);

  /// No description provided for @transactionFormExchangeRateRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعر صرف أكبر من صفر'**
  String get transactionFormExchangeRateRequired;

  /// No description provided for @transactionFormAmountHint.
  ///
  /// In ar, this message translates to:
  /// **'0.00'**
  String get transactionFormAmountHint;

  /// No description provided for @transactionEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العملية'**
  String get transactionEditTitle;

  /// No description provided for @transactionEditTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع العملية'**
  String get transactionEditTypeLabel;

  /// No description provided for @transactionEditSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get transactionEditSave;

  /// No description provided for @transactionEditSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعديلات بنجاح'**
  String get transactionEditSaveSuccess;

  /// No description provided for @transactionEditExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مدة التعديل المسموحة'**
  String get transactionEditExpired;

  /// No description provided for @transactionDeleteExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مدة الحذف المسموحة'**
  String get transactionDeleteExpired;

  /// No description provided for @transactionDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه العملية؟'**
  String get transactionDeleteConfirm;

  /// No description provided for @transactionDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العملية'**
  String get transactionDeleteSuccess;

  /// No description provided for @transactionDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get transactionDelete;

  /// No description provided for @transactionsListTransferCurrencyTitle.
  ///
  /// In ar, this message translates to:
  /// **'{from} → {to}'**
  String transactionsListTransferCurrencyTitle(String from, String to);

  /// No description provided for @transactionFormAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ المعاملة'**
  String get transactionFormAmountLabel;

  /// No description provided for @transactionFormAmountRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً أكبر من صفر'**
  String get transactionFormAmountRequired;

  /// No description provided for @transactionFormSelectCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة'**
  String get transactionFormSelectCurrency;

  /// No description provided for @transactionFormWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get transactionFormWallet;

  /// No description provided for @transactionFormSelectWallet.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحفظة'**
  String get transactionFormSelectWallet;

  /// No description provided for @transactionFormNoWalletForCurrency.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محفظة بهذه العملة. أضف رصيداً لهذه العملة في إحدى المحافظ.'**
  String get transactionFormNoWalletForCurrency;

  /// No description provided for @transactionFormCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get transactionFormCategory;

  /// No description provided for @categoryGeneralIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل عام'**
  String get categoryGeneralIncome;

  /// No description provided for @categoryGeneralExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف عام'**
  String get categoryGeneralExpense;

  /// No description provided for @transactionFormCategoryUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات غير جاهزة. أعد تشغيل التطبيق وحاول مرة أخرى.'**
  String get transactionFormCategoryUnavailable;

  /// No description provided for @categoriesTitleExpense.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفات المصروف'**
  String get categoriesTitleExpense;

  /// No description provided for @categoriesTitleIncome.
  ///
  /// In ar, this message translates to:
  /// **'تصنيفات الدخل'**
  String get categoriesTitleIncome;

  /// No description provided for @categoriesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تصنيفات بعد'**
  String get categoriesEmpty;

  /// No description provided for @categoryFormNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف جديد'**
  String get categoryFormNewTitle;

  /// No description provided for @categoryFormEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التصنيف'**
  String get categoryFormEditTitle;

  /// No description provided for @categoryFormName.
  ///
  /// In ar, this message translates to:
  /// **'اسم التصنيف'**
  String get categoryFormName;

  /// No description provided for @categoryFormNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: بقالة'**
  String get categoryFormNameHint;

  /// No description provided for @categoryFormNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get categoryFormNameRequired;

  /// No description provided for @categoryFormType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get categoryFormType;

  /// No description provided for @categoryFormTypeExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get categoryFormTypeExpense;

  /// No description provided for @categoryFormTypeIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get categoryFormTypeIncome;

  /// No description provided for @categoryFormIcon.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get categoryFormIcon;

  /// No description provided for @categoryFormColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get categoryFormColor;

  /// No description provided for @categoryFormSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get categoryFormSave;

  /// No description provided for @categoryFormCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get categoryFormCreate;

  /// No description provided for @categoryFormSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التصنيف بنجاح'**
  String get categoryFormSaveSuccess;

  /// No description provided for @categoryFormDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف التصنيف بنجاح'**
  String get categoryFormDeleteSuccess;

  /// No description provided for @categoryFormDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف التصنيف'**
  String get categoryFormDeleteTitle;

  /// No description provided for @categoryFormDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'حذف \"{name}\"؟'**
  String categoryFormDeleteMessage(String name);

  /// No description provided for @categoryFormHasTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الحذف: توجد معاملات مرتبطة بهذا التصنيف'**
  String get categoryFormHasTransactions;

  /// No description provided for @categoryFormSystemProtected.
  ///
  /// In ar, this message translates to:
  /// **'التصنيفات الأساسية لا يمكن تعديلها أو حذفها'**
  String get categoryFormSystemProtected;

  /// No description provided for @categoryFormSystemBadge.
  ///
  /// In ar, this message translates to:
  /// **'أساسي'**
  String get categoryFormSystemBadge;

  /// No description provided for @categoryFormNotFound.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف غير موجود'**
  String get categoryFormNotFound;

  /// No description provided for @transactionFormSelectCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختر التصنيف'**
  String get transactionFormSelectCategory;

  /// No description provided for @transactionFormMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get transactionFormMore;

  /// No description provided for @transactionFormCategoriesComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'إدارة التصنيفات ستتوفر قريباً'**
  String get transactionFormCategoriesComingSoon;

  /// No description provided for @transactionFormNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get transactionFormNotes;

  /// No description provided for @transactionFormNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصفاً قصيراً للعملية...'**
  String get transactionFormNotesHint;

  /// No description provided for @transactionFormDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ العملية'**
  String get transactionFormDate;

  /// No description provided for @transactionFormChangeDate.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get transactionFormChangeDate;

  /// No description provided for @transactionFormTodayDate.
  ///
  /// In ar, this message translates to:
  /// **'اليوم، {date}'**
  String transactionFormTodayDate(String date);

  /// No description provided for @transactionFormSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ العملية'**
  String get transactionFormSave;

  /// No description provided for @transactionFormSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ العملية بنجاح'**
  String get transactionFormSaveSuccess;

  /// No description provided for @transactionFormSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ العملية: {error}'**
  String transactionFormSaveError(String error);

  /// No description provided for @transactionsListTitle.
  ///
  /// In ar, this message translates to:
  /// **'العمليات'**
  String get transactionsListTitle;

  /// No description provided for @transactionsListTabAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get transactionsListTabAll;

  /// No description provided for @transactionsListTabExpenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get transactionsListTabExpenses;

  /// No description provided for @transactionsListTabIncomes.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get transactionsListTabIncomes;

  /// No description provided for @transactionsListTabTransfers.
  ///
  /// In ar, this message translates to:
  /// **'التحويلات'**
  String get transactionsListTabTransfers;

  /// No description provided for @transactionsListTabDebts.
  ///
  /// In ar, this message translates to:
  /// **'الذمم'**
  String get transactionsListTabDebts;

  /// No description provided for @transactionsListDebtReceivable.
  ///
  /// In ar, this message translates to:
  /// **'لي عليه'**
  String get transactionsListDebtReceivable;

  /// No description provided for @transactionsListDebtPayable.
  ///
  /// In ar, this message translates to:
  /// **'علي'**
  String get transactionsListDebtPayable;

  /// No description provided for @transactionsListDueDate.
  ///
  /// In ar, this message translates to:
  /// **'استحقاق {date}'**
  String transactionsListDueDate(String date);

  /// No description provided for @transactionsListDebtPaid.
  ///
  /// In ar, this message translates to:
  /// **'مسدّد'**
  String get transactionsListDebtPaid;

  /// No description provided for @transactionsListFilter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get transactionsListFilter;

  /// No description provided for @transactionsListThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get transactionsListThisMonth;

  /// No description provided for @transactionsListAllWallets.
  ///
  /// In ar, this message translates to:
  /// **'جميع المحافظ'**
  String get transactionsListAllWallets;

  /// No description provided for @transactionsListSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث في العمليات...'**
  String get transactionsListSearchHint;

  /// No description provided for @transactionsListEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات بعد.\nابدأ بتسجيل مصروف أو دخل.'**
  String get transactionsListEmpty;

  /// No description provided for @transactionsListUnknownWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة غير معروفة'**
  String get transactionsListUnknownWallet;

  /// No description provided for @transactionsListLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل العمليات: {error}'**
  String transactionsListLoadError(String error);

  /// No description provided for @transactionsListNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد بيانات'**
  String get transactionsListNoData;

  /// No description provided for @transactionsListLoadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get transactionsListLoadMore;

  /// No description provided for @transactionsListThisMonthHint.
  ///
  /// In ar, this message translates to:
  /// **'يعرض عمليات الشهر الحالي فقط — أوقف «هذا الشهر» لعرض الكل'**
  String get transactionsListThisMonthHint;

  /// No description provided for @transactionsListAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عملية'**
  String get transactionsListAdd;

  /// No description provided for @transactionsListSelectDetail.
  ///
  /// In ar, this message translates to:
  /// **'اختر عملية لعرض التفاصيل'**
  String get transactionsListSelectDetail;

  /// No description provided for @transactionsListTransferTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحويل من {from} إلى {to}'**
  String transactionsListTransferTitle(String from, String to);

  /// No description provided for @transactionsListGoalDepositTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيداع في {goal}'**
  String transactionsListGoalDepositTitle(String goal);

  /// No description provided for @transactionsListGoalDepositDetail.
  ///
  /// In ar, this message translates to:
  /// **'من محفظة {wallet}'**
  String transactionsListGoalDepositDetail(String wallet);

  /// No description provided for @transactionsListGoalWithdrawTitle.
  ///
  /// In ar, this message translates to:
  /// **'سحب من {goal}'**
  String transactionsListGoalWithdrawTitle(String goal);

  /// No description provided for @transactionsListGoalWithdrawDetail.
  ///
  /// In ar, this message translates to:
  /// **'إلى محفظة {wallet}'**
  String transactionsListGoalWithdrawDetail(String wallet);

  /// No description provided for @transactionsListNotesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get transactionsListNotesTitle;

  /// No description provided for @transactionsListNoNotes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات'**
  String get transactionsListNoNotes;

  /// No description provided for @transactionsListFilterTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفية العمليات'**
  String get transactionsListFilterTitle;

  /// No description provided for @transactionsListFilterDateFrom.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get transactionsListFilterDateFrom;

  /// No description provided for @transactionsListFilterDateTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get transactionsListFilterDateTo;

  /// No description provided for @transactionsListFilterCategory.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get transactionsListFilterCategory;

  /// No description provided for @transactionsListFilterType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العملية'**
  String get transactionsListFilterType;

  /// No description provided for @transactionsListFilterAllCategories.
  ///
  /// In ar, this message translates to:
  /// **'جميع التصنيفات'**
  String get transactionsListFilterAllCategories;

  /// No description provided for @transactionsListFilterAllTypes.
  ///
  /// In ar, this message translates to:
  /// **'جميع الأنواع'**
  String get transactionsListFilterAllTypes;

  /// No description provided for @transactionsListFilterApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get transactionsListFilterApply;

  /// No description provided for @transactionsListFilterReset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get transactionsListFilterReset;

  /// No description provided for @transactionsListDateToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم، {date}'**
  String transactionsListDateToday(String date);

  /// No description provided for @transactionsListDateYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس، {date}'**
  String transactionsListDateYesterday(String date);

  /// No description provided for @transactionsListSelectWallet.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحفظة'**
  String get transactionsListSelectWallet;

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

  /// No description provided for @settingsColorPalette.
  ///
  /// In ar, this message translates to:
  /// **'لوحة الألوان'**
  String get settingsColorPalette;

  /// No description provided for @paletteOriginal.
  ///
  /// In ar, this message translates to:
  /// **'الأصلي'**
  String get paletteOriginal;

  /// No description provided for @paletteDeepSea.
  ///
  /// In ar, this message translates to:
  /// **'أعماق البحر'**
  String get paletteDeepSea;

  /// No description provided for @paletteGothicGlam.
  ///
  /// In ar, this message translates to:
  /// **'الجلامور القوطي'**
  String get paletteGothicGlam;

  /// No description provided for @palettePurpleHaze.
  ///
  /// In ar, this message translates to:
  /// **'الضباب البنفسجي'**
  String get palettePurpleHaze;

  /// No description provided for @paletteTurquoiseHarmony.
  ///
  /// In ar, this message translates to:
  /// **'الانسجام الفيروزي'**
  String get paletteTurquoiseHarmony;

  /// No description provided for @settingsFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get settingsFontSize;

  /// No description provided for @settingsFontSizeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يُطبَّق على النصوص في التطبيق بالكامل'**
  String get settingsFontSizeSubtitle;

  /// No description provided for @settingsFontSizeDefault.
  ///
  /// In ar, this message translates to:
  /// **'افتراضي'**
  String get settingsFontSizeDefault;

  /// No description provided for @settingsFontSizeLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get settingsFontSizeLarge;

  /// No description provided for @settingsFontSizeExtraLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير جداً'**
  String get settingsFontSizeExtraLarge;

  /// No description provided for @settingsFontSizePreviewHeading.
  ///
  /// In ar, this message translates to:
  /// **'معاينة العنوان'**
  String get settingsFontSizePreviewHeading;

  /// No description provided for @settingsFontSizePreviewBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا نص تجريبي لمعاينة حجم الخط في الواجهة.'**
  String get settingsFontSizePreviewBody;

  /// No description provided for @settingsFontSizePreviewAmount.
  ///
  /// In ar, this message translates to:
  /// **'١٢٬٣٤٥٫٦٧ ر.س'**
  String get settingsFontSizePreviewAmount;

  /// No description provided for @settingsAmountFormat.
  ///
  /// In ar, this message translates to:
  /// **'تنسيق الأرقام'**
  String get settingsAmountFormat;

  /// No description provided for @settingsAmountFormatSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فاصل الآلاف والكسور العشرية'**
  String get settingsAmountFormatSubtitle;

  /// No description provided for @settingsAmountFormatWestern.
  ///
  /// In ar, this message translates to:
  /// **'1,234.56'**
  String get settingsAmountFormatWestern;

  /// No description provided for @settingsAmountFormatEuropean.
  ///
  /// In ar, this message translates to:
  /// **'1.234,56'**
  String get settingsAmountFormatEuropean;

  /// No description provided for @settingsAmountFormatPlain.
  ///
  /// In ar, this message translates to:
  /// **'1234.56'**
  String get settingsAmountFormatPlain;

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

  /// No description provided for @dashboardGoalsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف أهداف مالية بعد. ابدأ بتحديد هدفك الأول.'**
  String get dashboardGoalsEmpty;

  /// No description provided for @goalFormTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة هدف'**
  String get goalFormTitle;

  /// No description provided for @goalFormHeading.
  ///
  /// In ar, this message translates to:
  /// **'خطوتك القادمة'**
  String get goalFormHeading;

  /// No description provided for @goalFormSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد ملامح مستقبلك المالي بوضوح'**
  String get goalFormSubtitle;

  /// No description provided for @goalFormName.
  ///
  /// In ar, this message translates to:
  /// **'ما هو هدفك؟'**
  String get goalFormName;

  /// No description provided for @goalFormNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: شراء سيارة الأحلام'**
  String get goalFormNameHint;

  /// No description provided for @goalFormNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم الهدف مطلوب'**
  String get goalFormNameRequired;

  /// No description provided for @goalFormTargetAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب'**
  String get goalFormTargetAmount;

  /// No description provided for @goalFormSavedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدخر حالياً'**
  String get goalFormSavedAmount;

  /// No description provided for @goalFormAmountRequired.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ مطلوب'**
  String get goalFormAmountRequired;

  /// No description provided for @goalFormInvalidAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغاً صالحاً'**
  String get goalFormInvalidAmount;

  /// No description provided for @goalFormSavedExceedsTarget.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدخر لا يمكن أن يتجاوز المبلغ المطلوب'**
  String get goalFormSavedExceedsTarget;

  /// No description provided for @goalFormTargetDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنجاز المتوقع'**
  String get goalFormTargetDate;

  /// No description provided for @goalFormDateHint.
  ///
  /// In ar, this message translates to:
  /// **'mm/dd/yyyy'**
  String get goalFormDateHint;

  /// No description provided for @goalFormDateRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ الإنجاز المتوقع'**
  String get goalFormDateRequired;

  /// No description provided for @goalFormChooseIcon.
  ///
  /// In ar, this message translates to:
  /// **'اختر أيقونة للهدف'**
  String get goalFormChooseIcon;

  /// No description provided for @goalFormSelectCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة'**
  String get goalFormSelectCurrency;

  /// No description provided for @goalFormSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الهدف المالي'**
  String get goalFormSave;

  /// No description provided for @goalPlanTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخطة المقترحة'**
  String get goalPlanTitle;

  /// No description provided for @goalPlanIntro.
  ///
  /// In ar, this message translates to:
  /// **'بناءً على هدفك، نقترح عليك:'**
  String get goalPlanIntro;

  /// No description provided for @goalPlanMonthlyAmount.
  ///
  /// In ar, this message translates to:
  /// **'ادخر {amount} / شهرياً'**
  String goalPlanMonthlyAmount(String amount);

  /// No description provided for @goalPlanReachDate.
  ///
  /// In ar, this message translates to:
  /// **'ستصل لهدفك في {date}'**
  String goalPlanReachDate(String date);

  /// No description provided for @goalPlanWarningLargeAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الشهري المطلوب يتجاوز 50% من دخلك الشهري. قد يكون من الأفضل تمديد المدة أو تقليل المبلغ.'**
  String get goalPlanWarningLargeAmount;

  /// No description provided for @goalPlanWarningUnrealisticDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ المستهدف قد لا يكون واقعياً وفق دخلك ومصروفاتك. جرّب تعديل التاريخ أو المبلغ.'**
  String get goalPlanWarningUnrealisticDate;

  /// No description provided for @goalPlanAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول الخطة'**
  String get goalPlanAccept;

  /// No description provided for @goalPlanEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get goalPlanEdit;

  /// No description provided for @goalPlanCompare.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة'**
  String get goalPlanCompare;

  /// No description provided for @goalPlanCompareTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة الخطط'**
  String get goalPlanCompareTitle;

  /// No description provided for @goalPlanCompareTargetDate.
  ///
  /// In ar, this message translates to:
  /// **'حسب تاريخك المستهدف'**
  String get goalPlanCompareTargetDate;

  /// No description provided for @goalPlanCompareComfortable.
  ///
  /// In ar, this message translates to:
  /// **'خطة مريحة'**
  String get goalPlanCompareComfortable;

  /// No description provided for @goalPlanCompareExtended.
  ///
  /// In ar, this message translates to:
  /// **'خطة ممتدة'**
  String get goalPlanCompareExtended;

  /// No description provided for @goalPlanCompareMonthly.
  ///
  /// In ar, this message translates to:
  /// **'الادخار الشهري'**
  String get goalPlanCompareMonthly;

  /// No description provided for @goalPlanCompareDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الوصول'**
  String get goalPlanCompareDate;

  /// No description provided for @goalPlanCompareRecommended.
  ///
  /// In ar, this message translates to:
  /// **'الأنسب'**
  String get goalPlanCompareRecommended;

  /// No description provided for @goalPlanSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ الهدف: {error}'**
  String goalPlanSaveError(String error);

  /// No description provided for @goalEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الهدف'**
  String get goalEditTitle;

  /// No description provided for @goalEditHeading.
  ///
  /// In ar, this message translates to:
  /// **'تقدمك نحو الهدف'**
  String get goalEditHeading;

  /// No description provided for @goalEditSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عدّل بيانات هدفك المالي وتابع تقدمك'**
  String get goalEditSubtitle;

  /// No description provided for @goalEditProgress.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مكتمل'**
  String goalEditProgress(int percent);

  /// No description provided for @goalEditSavedOfTarget.
  ///
  /// In ar, this message translates to:
  /// **'ادخرت {saved} من {target}'**
  String goalEditSavedOfTarget(String saved, String target);

  /// No description provided for @goalEditSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get goalEditSave;

  /// No description provided for @goalEditNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الهدف غير موجود'**
  String get goalEditNotFound;

  /// No description provided for @goalEditSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التعديلات: {error}'**
  String goalEditSaveError(String error);

  /// No description provided for @goalEditDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الهدف'**
  String get goalEditDeleteTitle;

  /// No description provided for @goalEditDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الهدف؟ لا يمكن التراجع.'**
  String get goalEditDeleteMessage;

  /// No description provided for @goalEditDeleteError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف الهدف: {error}'**
  String goalEditDeleteError(String error);

  /// No description provided for @goalDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع'**
  String get goalDeposit;

  /// No description provided for @goalWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get goalWithdraw;

  /// No description provided for @goalTransferHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل التحويلات'**
  String get goalTransferHistory;

  /// No description provided for @goalThisMonthProgress.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر: {saved} / {required} مطلوب'**
  String goalThisMonthProgress(String saved, String required);

  /// No description provided for @goalWalletBadge.
  ///
  /// In ar, this message translates to:
  /// **'هدف'**
  String get goalWalletBadge;

  /// No description provided for @goalSelectSourceWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المصدر للمبلغ الافتتاحي'**
  String get goalSelectSourceWallet;

  /// No description provided for @goalSelectSourceWalletRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر محفظة المصدر للمبلغ المدخر الافتتاحي'**
  String get goalSelectSourceWalletRequired;

  /// No description provided for @goalInsufficientBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد المحفظة غير كافٍ'**
  String get goalInsufficientBalance;

  /// No description provided for @goalDeleteHasBalance.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف الهدف طالما يحتوي على مدخرات. اسحب المبلغ أولاً.'**
  String get goalDeleteHasBalance;

  /// No description provided for @goalSavedAmountReadOnly.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المدخر (من محفظة الهدف)'**
  String get goalSavedAmountReadOnly;

  /// No description provided for @goalTransferDeposit.
  ///
  /// In ar, this message translates to:
  /// **'إيداع للهدف'**
  String get goalTransferDeposit;

  /// No description provided for @goalTransferWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'سحب من الهدف'**
  String get goalTransferWithdraw;

  /// No description provided for @goalNoTransfersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحويلات بعد'**
  String get goalNoTransfersYet;

  /// No description provided for @goalSavingsDepositTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيداع للهدف'**
  String get goalSavingsDepositTitle;

  /// No description provided for @goalSavingsWithdrawTitle.
  ///
  /// In ar, this message translates to:
  /// **'سحب من الهدف'**
  String get goalSavingsWithdrawTitle;

  /// No description provided for @goalSavingsSelectWallet.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحفظة'**
  String get goalSavingsSelectWallet;

  /// No description provided for @goalSavingsAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get goalSavingsAmount;

  /// No description provided for @goalSavingsSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح'**
  String get goalSavingsSuccess;

  /// No description provided for @goalSavingsWalletCurrencyMismatch.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة المختارة لا تدعم عملة الهدف'**
  String get goalSavingsWalletCurrencyMismatch;

  /// No description provided for @goalSavingsGoalWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة الهدف'**
  String get goalSavingsGoalWallet;

  /// No description provided for @goalSavingsSourceWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المصدر'**
  String get goalSavingsSourceWallet;

  /// No description provided for @goalSavingsDestinationWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة الوجهة'**
  String get goalSavingsDestinationWallet;

  /// No description provided for @profileSectionAccount.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionFinancial.
  ///
  /// In ar, this message translates to:
  /// **'التفضيلات المالية'**
  String get profileSectionFinancial;

  /// No description provided for @profileSectionAppearance.
  ///
  /// In ar, this message translates to:
  /// **'مظهر التطبيق'**
  String get profileSectionAppearance;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get profilePersonalInfo;

  /// No description provided for @profileSecurity.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get profileSecurity;

  /// No description provided for @profileTwoFactor.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة الثنائية'**
  String get profileTwoFactor;

  /// No description provided for @profileTwoFactorSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get profileTwoFactorSubtitle;

  /// No description provided for @profileDefaultCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الافتراضية'**
  String get profileDefaultCurrency;

  /// No description provided for @profileLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة (Language)'**
  String get profileLanguage;

  /// No description provided for @profileLanguageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'العربية | English'**
  String get profileLanguageSubtitle;

  /// No description provided for @profileLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get profileLanguageArabic;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التنبيهات'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get profileNotificationsSubtitle;

  /// No description provided for @profileDarkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get profileDarkMode;

  /// No description provided for @profileAppearanceCustomize.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص المظهر'**
  String get profileAppearanceCustomize;

  /// No description provided for @profileLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد قفل الجلسة والخروج؟ ستحتاج PIN أو البصمة للدخول مجدداً.'**
  String get profileLogoutConfirmMessage;

  /// No description provided for @profileVersion.
  ///
  /// In ar, this message translates to:
  /// **'{appName} — النسخة {version}'**
  String profileVersion(String appName, String version);

  /// No description provided for @profileFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get profileFullName;

  /// No description provided for @profileFullNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get profileFullNameRequired;

  /// No description provided for @profileEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get profileEmail;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني غير صالح'**
  String get profileEmailInvalid;

  /// No description provided for @profilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get profilePhone;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المعلومات بنجاح'**
  String get profileSaveSuccess;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصورة الشخصية'**
  String get profileAvatarUpdated;

  /// No description provided for @profileChangePin.
  ///
  /// In ar, this message translates to:
  /// **'تغيير PIN'**
  String get profileChangePin;

  /// No description provided for @profileCurrentPin.
  ///
  /// In ar, this message translates to:
  /// **'PIN الحالي'**
  String get profileCurrentPin;

  /// No description provided for @profileNewPin.
  ///
  /// In ar, this message translates to:
  /// **'PIN الجديد'**
  String get profileNewPin;

  /// No description provided for @profileConfirmPin.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد PIN'**
  String get profileConfirmPin;

  /// No description provided for @profilePinMismatch.
  ///
  /// In ar, this message translates to:
  /// **'PIN غير متطابق'**
  String get profilePinMismatch;

  /// No description provided for @profilePinInvalid.
  ///
  /// In ar, this message translates to:
  /// **'PIN الحالي غير صحيح'**
  String get profilePinInvalid;

  /// No description provided for @profilePinUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث PIN بنجاح'**
  String get profilePinUpdated;

  /// No description provided for @profileBiometric.
  ///
  /// In ar, this message translates to:
  /// **'البصمة / Face ID'**
  String get profileBiometric;

  /// No description provided for @profileRecoveryCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الاسترداد'**
  String get profileRecoveryCode;

  /// No description provided for @profileRecoveryCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'احفظ هذا الرمز في مكان آمن'**
  String get profileRecoveryCodeHint;

  /// No description provided for @profileAppLock.
  ///
  /// In ar, this message translates to:
  /// **'قفل التطبيق الآن'**
  String get profileAppLock;

  /// No description provided for @profileAppLockSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب PIN أو البصمة للدخول مجدداً'**
  String get profileAppLockSubtitle;

  /// No description provided for @profileSelectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get profileSelectLanguage;

  /// No description provided for @quickActionAddTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get quickActionAddTransaction;

  /// No description provided for @quickActionTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get quickActionTransfer;

  /// No description provided for @quickActionViewAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get quickActionViewAll;

  /// No description provided for @statusOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get statusOffline;

  /// No description provided for @statusOfflineData.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك محفوظة على جهازك'**
  String get statusOfflineData;

  /// No description provided for @transactionConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد العملية'**
  String get transactionConfirmTitle;

  /// No description provided for @transactionConfirmSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع التفاصيل قبل الحفظ'**
  String get transactionConfirmSubtitle;

  /// No description provided for @transactionConfirmSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get transactionConfirmSave;

  /// No description provided for @goalAchievedTitle.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت!'**
  String get goalAchievedTitle;

  /// No description provided for @goalAchievedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لقد حققت هدفك المالي'**
  String get goalAchievedSubtitle;
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
