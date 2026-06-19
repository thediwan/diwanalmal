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
  String get feedbackDatabaseError =>
      'حدث خطأ في قاعدة البيانات. أعد تشغيل التطبيق بالكامل.';

  @override
  String get walletFormSaveSuccess => 'تم حفظ المحفظة بنجاح';

  @override
  String get walletFormDeleteSuccess => 'تم حذف المحفظة بنجاح';

  @override
  String get currencyFormSaveSuccess => 'تم حفظ العملة بنجاح';

  @override
  String get currencyDeleteSuccess => 'تم حذف العملة بنجاح';

  @override
  String get goalPlanSaveSuccess => 'تم حفظ الهدف بنجاح';

  @override
  String get goalEditSaveSuccess => 'تم تحديث الهدف بنجاح';

  @override
  String get goalEditDeleteSuccess => 'تم حذف الهدف بنجاح';

  @override
  String get onboardingBaseCurrencySuccess => 'تم تعيين العملة الأساسية بنجاح';

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
  String get dashboardBalanceCardType => 'محفظة رقمية';

  @override
  String get dashboardBalanceCardHolder => 'الحامل';

  @override
  String get dashboardBalanceCardExpDate => 'تاريخ الصلاحية';

  @override
  String get dashboardCardMenuTitle => 'خيارات البطاقة';

  @override
  String get dashboardCardMenuViewWallets => 'عرض المحافظ';

  @override
  String get dashboardCardMenuAddTransaction => 'إضافة معاملة';

  @override
  String get dashboardCardMenuTransfer => 'تحويل';

  @override
  String get dashboardCardMenuViewStats => 'الإحصائيات';

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
  String get dashboardLast7Days => 'آخر 7 أيام';

  @override
  String get dashboardLast4Weeks => 'آخر 4 أسابيع';

  @override
  String get dashboardDaily => 'يومي';

  @override
  String get dashboardWeekly => 'أسبوعي';

  @override
  String get dashboardChartMin => 'الأقل';

  @override
  String get dashboardChartMax => 'الأعلى';

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
  String get transactionFormExpense => 'مصروف';

  @override
  String get transactionFormIncome => 'دخل';

  @override
  String get transactionFormCurrencyTransfer => 'تحويل بين عملات';

  @override
  String get transactionFormDebtor => 'مدين (لي عليه)';

  @override
  String get transactionFormCreditor => 'دائن (علي)';

  @override
  String get transactionFormPersonName => 'اسم الشخص';

  @override
  String get transactionFormPersonNameHint => 'أدخل اسم الشخص';

  @override
  String get transactionFormPersonNameRequired => 'أدخل اسم الشخص';

  @override
  String get transactionFormDueDate => 'تاريخ الاستحقاق';

  @override
  String get transactionFormDueDateOptional => 'اختياري — اضغط للتحديد';

  @override
  String get transactionFormClearDueDate => 'مسح تاريخ الاستحقاق';

  @override
  String get transactionFormDebtLedgerHint =>
      'قيد الذمة لا يؤثر على رصيد المحفظة حتى الدفع أو التحصيل.';

  @override
  String get transactionFormDebtSaveSuccess => 'تم حفظ قيد الذمة بنجاح';

  @override
  String get transactionDebtTotal => 'الإجمالي';

  @override
  String get transactionDebtPaid => 'المدفوع';

  @override
  String get transactionDebtRemaining => 'المتبقي';

  @override
  String get transactionDebtPaymentHistory => 'سجل الدفعات';

  @override
  String get transactionDebtNoPayments => 'لا توجد دفعات بعد';

  @override
  String get transactionDebtReceive => 'تحصيل';

  @override
  String get transactionDebtPay => 'دفع';

  @override
  String get transactionDebtSettleTitle => 'مبلغ التسديد';

  @override
  String get transactionDebtSettleHint => 'أدخل المبلغ للدفع أو التحصيل';

  @override
  String get transactionDebtSettleConfirm => 'تأكيد';

  @override
  String get transactionDebtSettleSuccess => 'تم تسجيل الدفعة بنجاح';

  @override
  String get transactionDebtSettleExceedsRemaining => 'المبلغ أكبر من المتبقي';

  @override
  String get transactionDebtFullyPaid => 'مسدّد بالكامل';

  @override
  String transactionDebtSettlementTitleReceive(String person) {
    return 'تحصيل — $person';
  }

  @override
  String transactionDebtSettlementTitlePay(String person) {
    return 'دفع — $person';
  }

  @override
  String get transactionFormSourceCurrency => 'العملة المصدر';

  @override
  String get transactionFormTargetCurrency => 'العملة الهدف';

  @override
  String get transactionFormSourceWallet => 'المحفظة المصدر';

  @override
  String get transactionFormTargetWallet => 'المحفظة الهدف';

  @override
  String transactionFormConvertedAmount(String amount) {
    return 'المبلغ المحوّل: $amount';
  }

  @override
  String get transactionFormTransferSaveSuccess => 'تم حفظ التحويل بنجاح';

  @override
  String get transactionFormSelectSourceCurrency => 'اختر العملة المصدر';

  @override
  String get transactionFormSelectTargetCurrency => 'اختر العملة الهدف';

  @override
  String get transactionFormSelectSourceWallet => 'اختر المحفظة المصدر';

  @override
  String get transactionFormSelectTargetWallet => 'اختر المحفظة الهدف';

  @override
  String get transactionFormTransferSameError =>
      'يجب أن تختلف العملة أو المحفظة بين المصدر والهدف';

  @override
  String get transactionFormExchangeRate => 'سعر الصرف';

  @override
  String transactionFormExchangeRateHint(String source, String target) {
    return '1 $source = ? $target';
  }

  @override
  String get transactionFormExchangeRateRequired => 'أدخل سعر صرف أكبر من صفر';

  @override
  String get transactionFormAmountHint => '0.00';

  @override
  String get transactionEditTitle => 'تعديل العملية';

  @override
  String get transactionEditTypeLabel => 'نوع العملية';

  @override
  String get transactionEditSave => 'حفظ التعديلات';

  @override
  String get transactionEditSaveSuccess => 'تم حفظ التعديلات بنجاح';

  @override
  String get transactionEditExpired => 'انتهت مدة التعديل المسموحة';

  @override
  String get transactionDeleteExpired => 'انتهت مدة الحذف المسموحة';

  @override
  String get transactionDeleteConfirm => 'هل تريد حذف هذه العملية؟';

  @override
  String get transactionDeleteSuccess => 'تم حذف العملية';

  @override
  String get transactionDelete => 'حذف';

  @override
  String transactionsListTransferCurrencyTitle(String from, String to) {
    return '$from → $to';
  }

  @override
  String get transactionFormAmountLabel => 'مبلغ المعاملة';

  @override
  String get transactionFormAmountRequired => 'أدخل مبلغاً أكبر من صفر';

  @override
  String get transactionFormSelectCurrency => 'اختر العملة';

  @override
  String get transactionFormWallet => 'المحفظة';

  @override
  String get transactionFormSelectWallet => 'اختر المحفظة';

  @override
  String get transactionFormNoWalletForCurrency =>
      'لا توجد محفظة بهذه العملة. أضف رصيداً لهذه العملة في إحدى المحافظ.';

  @override
  String get transactionFormCategory => 'التصنيف';

  @override
  String get categoryGeneralIncome => 'دخل عام';

  @override
  String get categoryGeneralExpense => 'مصروف عام';

  @override
  String get transactionFormCategoryUnavailable =>
      'التصنيفات غير جاهزة. أعد تشغيل التطبيق وحاول مرة أخرى.';

  @override
  String get categoriesTitleExpense => 'تصنيفات المصروف';

  @override
  String get categoriesTitleIncome => 'تصنيفات الدخل';

  @override
  String get categoriesEmpty => 'لا توجد تصنيفات بعد';

  @override
  String get categoryFormNewTitle => 'تصنيف جديد';

  @override
  String get categoryFormEditTitle => 'تعديل التصنيف';

  @override
  String get categoryFormName => 'اسم التصنيف';

  @override
  String get categoryFormNameHint => 'مثال: بقالة';

  @override
  String get categoryFormNameRequired => 'الاسم مطلوب';

  @override
  String get categoryFormType => 'النوع';

  @override
  String get categoryFormTypeExpense => 'مصروف';

  @override
  String get categoryFormTypeIncome => 'دخل';

  @override
  String get categoryFormIcon => 'الأيقونة';

  @override
  String get categoryFormColor => 'اللون';

  @override
  String get categoryFormSave => 'حفظ';

  @override
  String get categoryFormCreate => 'إنشاء';

  @override
  String get categoryFormSaveSuccess => 'تم حفظ التصنيف بنجاح';

  @override
  String get categoryFormDeleteSuccess => 'تم حذف التصنيف بنجاح';

  @override
  String get categoryFormDeleteTitle => 'حذف التصنيف';

  @override
  String categoryFormDeleteMessage(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get categoryFormHasTransactions =>
      'لا يمكن الحذف: توجد معاملات مرتبطة بهذا التصنيف';

  @override
  String get categoryFormSystemProtected =>
      'التصنيفات الأساسية لا يمكن تعديلها أو حذفها';

  @override
  String get categoryFormSystemBadge => 'أساسي';

  @override
  String get categoryFormNotFound => 'التصنيف غير موجود';

  @override
  String get transactionFormSelectCategory => 'اختر التصنيف';

  @override
  String get transactionFormMore => 'المزيد';

  @override
  String get transactionFormCategoriesComingSoon =>
      'إدارة التصنيفات ستتوفر قريباً';

  @override
  String get transactionFormNotes => 'ملاحظات';

  @override
  String get transactionFormNotesHint => 'اكتب وصفاً قصيراً للعملية...';

  @override
  String get transactionFormDate => 'تاريخ العملية';

  @override
  String get transactionFormChangeDate => 'تغيير';

  @override
  String transactionFormTodayDate(String date) {
    return 'اليوم، $date';
  }

  @override
  String get transactionFormSave => 'حفظ العملية';

  @override
  String get transactionFormSaveSuccess => 'تم حفظ العملية بنجاح';

  @override
  String transactionFormSaveError(String error) {
    return 'تعذر حفظ العملية: $error';
  }

  @override
  String get transactionsListTitle => 'العمليات';

  @override
  String get transactionsListTabAll => 'الكل';

  @override
  String get transactionsListTabExpenses => 'المصروفات';

  @override
  String get transactionsListTabIncomes => 'الإيرادات';

  @override
  String get transactionsListTabTransfers => 'التحويلات';

  @override
  String get transactionsListTabDebts => 'الذمم';

  @override
  String get transactionsListDebtReceivable => 'لي عليه';

  @override
  String get transactionsListDebtPayable => 'علي';

  @override
  String transactionsListDueDate(String date) {
    return 'استحقاق $date';
  }

  @override
  String get transactionsListDebtPaid => 'مسدّد';

  @override
  String get transactionsListFilter => 'تصفية';

  @override
  String get transactionsListThisMonth => 'هذا الشهر';

  @override
  String get transactionsListAllWallets => 'جميع المحافظ';

  @override
  String get transactionsListSearchHint => 'بحث في العمليات...';

  @override
  String get transactionsListEmpty =>
      'لا توجد عمليات بعد.\nابدأ بتسجيل مصروف أو دخل.';

  @override
  String get transactionsListUnknownWallet => 'محفظة غير معروفة';

  @override
  String transactionsListLoadError(String error) {
    return 'تعذر تحميل العمليات: $error';
  }

  @override
  String get transactionsListNoData => 'لا يوجد بيانات';

  @override
  String get transactionsListLoadMore => 'عرض المزيد';

  @override
  String get transactionsListThisMonthHint =>
      'يعرض عمليات الشهر الحالي فقط — أوقف «هذا الشهر» لعرض الكل';

  @override
  String get transactionsListAdd => 'إضافة عملية';

  @override
  String get transactionsListSelectDetail => 'اختر عملية لعرض التفاصيل';

  @override
  String transactionsListTransferTitle(String from, String to) {
    return 'تحويل من $from إلى $to';
  }

  @override
  String transactionsListGoalDepositTitle(String goal) {
    return 'إيداع في $goal';
  }

  @override
  String transactionsListGoalDepositDetail(String wallet) {
    return 'من محفظة $wallet';
  }

  @override
  String transactionsListGoalWithdrawTitle(String goal) {
    return 'سحب من $goal';
  }

  @override
  String transactionsListGoalWithdrawDetail(String wallet) {
    return 'إلى محفظة $wallet';
  }

  @override
  String get transactionsListNotesTitle => 'ملاحظات';

  @override
  String get transactionsListNoNotes => 'لا توجد ملاحظات';

  @override
  String get transactionsListFilterTitle => 'تصفية العمليات';

  @override
  String get transactionsListFilterDateFrom => 'من تاريخ';

  @override
  String get transactionsListFilterDateTo => 'إلى تاريخ';

  @override
  String get transactionsListFilterCategory => 'التصنيف';

  @override
  String get transactionsListFilterType => 'نوع العملية';

  @override
  String get transactionsListFilterAllCategories => 'جميع التصنيفات';

  @override
  String get transactionsListFilterAllTypes => 'جميع الأنواع';

  @override
  String get transactionsListFilterApply => 'تطبيق';

  @override
  String get transactionsListFilterReset => 'إعادة تعيين';

  @override
  String transactionsListDateToday(String date) {
    return 'اليوم، $date';
  }

  @override
  String transactionsListDateYesterday(String date) {
    return 'أمس، $date';
  }

  @override
  String get transactionsListSelectWallet => 'اختر المحفظة';

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
  String get settingsColorPalette => 'لوحة الألوان';

  @override
  String get paletteOriginal => 'الأصلي';

  @override
  String get paletteDeepSea => 'أعماق البحر';

  @override
  String get paletteGothicGlam => 'الجلامور القوطي';

  @override
  String get palettePurpleHaze => 'الضباب البنفسجي';

  @override
  String get paletteTurquoiseHarmony => 'الانسجام الفيروزي';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsFontSizeSubtitle =>
      'يُطبَّق على النصوص في التطبيق بالكامل';

  @override
  String get settingsFontSizeDefault => 'افتراضي';

  @override
  String get settingsFontSizeLarge => 'كبير';

  @override
  String get settingsFontSizeExtraLarge => 'كبير جداً';

  @override
  String get settingsFontSizePreviewHeading => 'معاينة العنوان';

  @override
  String get settingsFontSizePreviewBody =>
      'هذا نص تجريبي لمعاينة حجم الخط في الواجهة.';

  @override
  String get settingsFontSizePreviewAmount => '١٢٬٣٤٥٫٦٧ ر.س';

  @override
  String get settingsAmountFormat => 'تنسيق الأرقام';

  @override
  String get settingsAmountFormatSubtitle => 'فاصل الآلاف والكسور العشرية';

  @override
  String get settingsAmountFormatWestern => '1,234.56';

  @override
  String get settingsAmountFormatEuropean => '1.234,56';

  @override
  String get settingsAmountFormatPlain => '1234.56';

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

  @override
  String get dashboardGoalsEmpty =>
      'لم تُضف أهداف مالية بعد. ابدأ بتحديد هدفك الأول.';

  @override
  String get goalFormTitle => 'إضافة هدف';

  @override
  String get goalFormHeading => 'خطوتك القادمة';

  @override
  String get goalFormSubtitle => 'حدد ملامح مستقبلك المالي بوضوح';

  @override
  String get goalFormName => 'ما هو هدفك؟';

  @override
  String get goalFormNameHint => 'مثلاً: شراء سيارة الأحلام';

  @override
  String get goalFormNameRequired => 'اسم الهدف مطلوب';

  @override
  String get goalFormTargetAmount => 'المبلغ المطلوب';

  @override
  String get goalFormSavedAmount => 'المبلغ المدخر حالياً';

  @override
  String get goalFormAmountRequired => 'المبلغ مطلوب';

  @override
  String get goalFormInvalidAmount => 'أدخل مبلغاً صالحاً';

  @override
  String get goalFormSavedExceedsTarget =>
      'المبلغ المدخر لا يمكن أن يتجاوز المبلغ المطلوب';

  @override
  String get goalFormTargetDate => 'تاريخ الإنجاز المتوقع';

  @override
  String get goalFormDateHint => 'mm/dd/yyyy';

  @override
  String get goalFormDateRequired => 'اختر تاريخ الإنجاز المتوقع';

  @override
  String get goalFormChooseIcon => 'اختر أيقونة للهدف';

  @override
  String get goalFormSelectCurrency => 'اختر العملة';

  @override
  String get goalFormSave => 'حفظ الهدف المالي';

  @override
  String get goalPlanTitle => 'الخطة المقترحة';

  @override
  String get goalPlanIntro => 'بناءً على هدفك، نقترح عليك:';

  @override
  String goalPlanMonthlyAmount(String amount) {
    return 'ادخر $amount / شهرياً';
  }

  @override
  String goalPlanReachDate(String date) {
    return 'ستصل لهدفك في $date';
  }

  @override
  String get goalPlanWarningLargeAmount =>
      'المبلغ الشهري المطلوب يتجاوز 50% من دخلك الشهري. قد يكون من الأفضل تمديد المدة أو تقليل المبلغ.';

  @override
  String get goalPlanWarningUnrealisticDate =>
      'التاريخ المستهدف قد لا يكون واقعياً وفق دخلك ومصروفاتك. جرّب تعديل التاريخ أو المبلغ.';

  @override
  String get goalPlanAccept => 'قبول الخطة';

  @override
  String get goalPlanEdit => 'تعديل';

  @override
  String get goalPlanCompare => 'مقارنة';

  @override
  String get goalPlanCompareTitle => 'مقارنة الخطط';

  @override
  String get goalPlanCompareTargetDate => 'حسب تاريخك المستهدف';

  @override
  String get goalPlanCompareComfortable => 'خطة مريحة';

  @override
  String get goalPlanCompareExtended => 'خطة ممتدة';

  @override
  String get goalPlanCompareMonthly => 'الادخار الشهري';

  @override
  String get goalPlanCompareDate => 'تاريخ الوصول';

  @override
  String get goalPlanCompareRecommended => 'الأنسب';

  @override
  String goalPlanSaveError(String error) {
    return 'تعذر حفظ الهدف: $error';
  }

  @override
  String get goalEditTitle => 'تعديل الهدف';

  @override
  String get goalEditHeading => 'تقدمك نحو الهدف';

  @override
  String get goalEditSubtitle => 'عدّل بيانات هدفك المالي وتابع تقدمك';

  @override
  String goalEditProgress(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String goalEditSavedOfTarget(String saved, String target) {
    return 'ادخرت $saved من $target';
  }

  @override
  String get goalEditSave => 'حفظ التعديلات';

  @override
  String get goalEditNotFound => 'الهدف غير موجود';

  @override
  String goalEditSaveError(String error) {
    return 'تعذر حفظ التعديلات: $error';
  }

  @override
  String get goalEditDeleteTitle => 'حذف الهدف';

  @override
  String get goalEditDeleteMessage =>
      'هل أنت متأكد من حذف هذا الهدف؟ لا يمكن التراجع.';

  @override
  String goalEditDeleteError(String error) {
    return 'تعذر حذف الهدف: $error';
  }

  @override
  String get goalDeposit => 'إيداع';

  @override
  String get goalWithdraw => 'سحب';

  @override
  String get goalTransferHistory => 'سجل التحويلات';

  @override
  String goalThisMonthProgress(String saved, String required) {
    return 'هذا الشهر: $saved / $required مطلوب';
  }

  @override
  String get goalWalletBadge => 'هدف';

  @override
  String get goalSelectSourceWallet => 'محفظة المصدر للمبلغ الافتتاحي';

  @override
  String get goalSelectSourceWalletRequired =>
      'اختر محفظة المصدر للمبلغ المدخر الافتتاحي';

  @override
  String get goalInsufficientBalance => 'رصيد المحفظة غير كافٍ';

  @override
  String get goalDeleteHasBalance =>
      'لا يمكن حذف الهدف طالما يحتوي على مدخرات. اسحب المبلغ أولاً.';

  @override
  String get goalSavedAmountReadOnly => 'المبلغ المدخر (من محفظة الهدف)';

  @override
  String get goalTransferDeposit => 'إيداع للهدف';

  @override
  String get goalTransferWithdraw => 'سحب من الهدف';

  @override
  String get goalNoTransfersYet => 'لا توجد تحويلات بعد';

  @override
  String get goalSavingsDepositTitle => 'إيداع للهدف';

  @override
  String get goalSavingsWithdrawTitle => 'سحب من الهدف';

  @override
  String get goalSavingsSelectWallet => 'اختر المحفظة';

  @override
  String get goalSavingsAmount => 'المبلغ';

  @override
  String get goalSavingsSuccess => 'تمت العملية بنجاح';

  @override
  String get goalSavingsWalletCurrencyMismatch =>
      'المحفظة المختارة لا تدعم عملة الهدف';

  @override
  String get goalSavingsGoalWallet => 'محفظة الهدف';

  @override
  String get goalSavingsSourceWallet => 'محفظة المصدر';

  @override
  String get goalSavingsDestinationWallet => 'محفظة الوجهة';

  @override
  String get profileSectionAccount => 'إعدادات الحساب';

  @override
  String get profileSectionFinancial => 'التفضيلات المالية';

  @override
  String get profileSectionAppearance => 'مظهر التطبيق';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileSecurity => 'الأمان';

  @override
  String get profileTwoFactor => 'المصادقة الثنائية';

  @override
  String get profileTwoFactorSubtitle => 'قريباً';

  @override
  String get profileDefaultCurrency => 'العملة الافتراضية';

  @override
  String get profileLanguage => 'اللغة (Language)';

  @override
  String get profileLanguageSubtitle => 'العربية | English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileNotifications => 'إعدادات التنبيهات';

  @override
  String get profileNotificationsSubtitle => 'قريباً';

  @override
  String get profileDarkMode => 'الوضع الداكن';

  @override
  String get profileAppearanceCustomize => 'تخصيص المظهر';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutConfirmMessage =>
      'هل تريد قفل الجلسة والخروج؟ ستحتاج PIN أو البصمة للدخول مجدداً.';

  @override
  String profileVersion(String appName, String version) {
    return '$appName — النسخة $version';
  }

  @override
  String get profileFullName => 'الاسم الكامل';

  @override
  String get profileFullNameRequired => 'الاسم مطلوب';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileEmailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String get profilePhone => 'رقم الهاتف';

  @override
  String get profileSaveSuccess => 'تم حفظ المعلومات بنجاح';

  @override
  String get profileAvatarUpdated => 'تم تحديث الصورة الشخصية';

  @override
  String get profileChangePin => 'تغيير PIN';

  @override
  String get profileCurrentPin => 'PIN الحالي';

  @override
  String get profileNewPin => 'PIN الجديد';

  @override
  String get profileConfirmPin => 'تأكيد PIN';

  @override
  String get profilePinMismatch => 'PIN غير متطابق';

  @override
  String get profilePinInvalid => 'PIN الحالي غير صحيح';

  @override
  String get profilePinUpdated => 'تم تحديث PIN بنجاح';

  @override
  String get profileBiometric => 'البصمة / Face ID';

  @override
  String get profileRecoveryCode => 'رمز الاسترداد';

  @override
  String get profileRecoveryCodeHint => 'احفظ هذا الرمز في مكان آمن';

  @override
  String get profileAppLock => 'قفل التطبيق الآن';

  @override
  String get profileAppLockSubtitle => 'يتطلب PIN أو البصمة للدخول مجدداً';

  @override
  String get profileSelectLanguage => 'اختر اللغة';

  @override
  String get quickActionAddTransaction => 'إضافة';

  @override
  String get quickActionTransfer => 'تحويل';

  @override
  String get quickActionViewAll => 'الكل';

  @override
  String get statusOffline => 'غير متصل';

  @override
  String get statusOfflineData => 'بياناتك محفوظة على جهازك';

  @override
  String get transactionConfirmTitle => 'تأكيد العملية';

  @override
  String get transactionConfirmSubtitle => 'راجع التفاصيل قبل الحفظ';

  @override
  String get transactionConfirmSave => 'حفظ';

  @override
  String get goalAchievedTitle => 'أحسنت!';

  @override
  String get goalAchievedSubtitle => 'لقد حققت هدفك المالي';
}
