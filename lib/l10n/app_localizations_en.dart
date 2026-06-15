// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dewan Al-Mal';

  @override
  String get appTagline => 'Your financial future, with ethical standards';

  @override
  String get routeError => 'Unable to open this screen';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Next';

  @override
  String get login => 'Sign in';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get errorGeneric => 'Something went wrong, try again';

  @override
  String errorGenericWithDetail(String detail) {
    return 'Something went wrong: $detail';
  }

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginSubtitle =>
      'Enter your credentials to access your account';

  @override
  String get authEmailOrPhone => 'Email or phone';

  @override
  String get authEmailHint => 'example@mail.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authRememberDevice => 'Remember me on this device';

  @override
  String get authInvalidCredentials => 'Invalid credentials';

  @override
  String get authInvalidPassword => 'Invalid password';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authCreateAccountLink => 'Create an account';

  @override
  String get authRegisterTagline => 'Grow smarter and safer with you';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernameHint => 'Enter your full name';

  @override
  String get authNameRequired => 'Name is required';

  @override
  String get authPasswordShort => 'Password is too short';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authTermsRequired => 'You must accept the terms and conditions';

  @override
  String get authTermsPrefix => 'By creating an account, you agree to the ';

  @override
  String get authTerms => 'Terms and Conditions';

  @override
  String get authTermsAnd => ' and ';

  @override
  String get authPrivacy => 'Privacy Policy';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authHasAccount => 'Already have an account? ';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authStartNoAccount => 'Create an account or sign in to continue';

  @override
  String authStartWithAccount(String appName) {
    return 'Verify your identity to continue to $appName';
  }

  @override
  String get authStartBiometric => 'Start authentication';

  @override
  String get authUsePin => 'Use PIN';

  @override
  String get authUsePassword => 'Use password';

  @override
  String get authCreateAccountNew => 'Create new account';

  @override
  String get authBankGradeSecurity => 'Bank-grade encryption and protection';

  @override
  String get authCopyright =>
      '© 2024 Dewan Al-Mal Financial Services. All rights reserved.';

  @override
  String get authBiometricFailed => 'Biometric failed, use PIN';

  @override
  String get authUnlockSubtitle => 'Enter PIN or use biometric';

  @override
  String get authUseBiometric => 'Use biometric';

  @override
  String get authPinInvalid => 'Invalid PIN';

  @override
  String get authBiometricSetupFailed => 'Biometric authentication failed';

  @override
  String get authFingerprint => 'Fingerprint';

  @override
  String get authFingerprintDesc => 'Use biometrics for fast, secure sign-in';

  @override
  String get authSetupFingerprint => 'Set up fingerprint';

  @override
  String get authFingerprintDone => 'Fingerprint set up ✓';

  @override
  String get authFingerprintSuccess => 'Fingerprint set up successfully';

  @override
  String get authFingerprintError => 'Could not set up fingerprint';

  @override
  String get authPinPersonal => 'Personal PIN';

  @override
  String get authPinReenter => 'Re-enter PIN';

  @override
  String get authPinConfirmHint => 'Confirm PIN to continue';

  @override
  String get authPinEnterHint => 'Enter 4 digits to secure your transactions';

  @override
  String get authPinMinDigits => 'Enter 4 digits';

  @override
  String get authPinMismatch => 'PIN does not match';

  @override
  String get authSavePin => 'Save PIN';

  @override
  String get authSecurityCodeFailed => 'Could not create security code';

  @override
  String get authAccountCreated => 'Account created successfully!';

  @override
  String get authSecurityCodeHint =>
      'Save this security code to recover your password if you lose it.';

  @override
  String get authSecurityCodeLoadError =>
      'Could not load security code. Restart the app or register again.';

  @override
  String get authYourSecurityCode => 'Your security code';

  @override
  String get authCopyCode => 'Copy code';

  @override
  String get authCodeCopied => 'Code copied';

  @override
  String get authSecurityWarning =>
      'Warning: Never share this code. Dewan Al-Mal staff will never ask for it.';

  @override
  String get authGoToCurrency => 'You will choose your base currency next';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authResetPasswordDesc =>
      'Enter the security code you saved at registration and your new password.';

  @override
  String get authSecurityCode => 'Security code';

  @override
  String get authSecurityCodeInvalid => 'Enter the 6-character security code';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authNewPasswordShort => 'Password must be at least 6 characters';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authNoLocalAccount => 'No account is registered on this device.';

  @override
  String get authNoAccountOnDevice => 'No account on this device';

  @override
  String get authWrongSecurityCode => 'Incorrect security code';

  @override
  String get authPasswordChanged => 'Password changed successfully';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navWallets => 'Wallets';

  @override
  String get navSettings => 'Settings';

  @override
  String get dashboardMyCurrencies => 'My currencies & balances';

  @override
  String get dashboardNoCurrencyBalances => 'No wallet balances yet';

  @override
  String dashboardTotalBalance(String code) {
    return 'Total balance ($code)';
  }

  @override
  String dashboardApproxBase(String amount) {
    return '≈ $amount';
  }

  @override
  String get dashboardMonthlyIncome => 'Monthly income';

  @override
  String get dashboardMonthlyExpense => 'Monthly expenses';

  @override
  String get dashboardDebts => 'Debts';

  @override
  String get dashboardDebtsOwedToOthers => 'Owed to others';

  @override
  String dashboardIncomeChange(int percent) {
    return '+$percent% ↑';
  }

  @override
  String dashboardExpenseChange(int percent) {
    return '-$percent% ↓';
  }

  @override
  String get dashboardFinancialGoals => 'Financial goals';

  @override
  String get dashboardAddGoal => 'Add goal';

  @override
  String get dashboardExpenseAnalysis => 'Expense analysis';

  @override
  String get dashboardLast30Days => 'Last 30 days';

  @override
  String get dashboardDaily => 'Daily';

  @override
  String get dashboardWeekly => 'Weekly';

  @override
  String get dashboardRecentTransactions => 'Recent transactions';

  @override
  String get dashboardMore => 'More';

  @override
  String get dashboardToday => 'Today';

  @override
  String get dashboardYesterday => 'Yesterday';

  @override
  String get dashboardGoalBuyCar => 'Buy a car';

  @override
  String get dashboardTxGroceryTitle => 'Al-Majd Grocery';

  @override
  String get dashboardTxGroceryTime => 'Today, 10:30 AM';

  @override
  String get dashboardTxSalaryTitle => 'Monthly salary';

  @override
  String get dashboardTxSalaryTime => 'Yesterday, 9:00 AM';

  @override
  String get dashboardChartMay1 => 'May 1';

  @override
  String get dashboardChartMay10 => 'May 10';

  @override
  String get dashboardChartMay20 => 'May 20';

  @override
  String get dashboardChartMay30 => 'May 30';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileComingSoon => 'Profile page is under development';

  @override
  String get transactionAddTitle => 'Add transaction';

  @override
  String get transactionAddComingSoon =>
      'Adding transactions will be available soon';

  @override
  String get transactionFormExpense => 'Expense';

  @override
  String get transactionFormIncome => 'Income';

  @override
  String get transactionFormAmountLabel => 'Transaction amount';

  @override
  String get transactionFormAmountRequired =>
      'Enter an amount greater than zero';

  @override
  String get transactionFormSelectCurrency => 'Select a currency';

  @override
  String get transactionFormWallet => 'Wallet';

  @override
  String get transactionFormSelectWallet => 'Select a wallet';

  @override
  String get transactionFormNoWalletForCurrency =>
      'No wallet with this currency. Add a balance in this currency to a wallet first.';

  @override
  String get transactionFormCategory => 'Category';

  @override
  String get transactionFormSelectCategory => 'Select a category';

  @override
  String get transactionFormMore => 'More';

  @override
  String get transactionFormCategoriesComingSoon =>
      'Category management coming soon';

  @override
  String get transactionFormNotes => 'Notes';

  @override
  String get transactionFormNotesHint =>
      'Write a short description for this transaction...';

  @override
  String get transactionFormDate => 'Transaction date';

  @override
  String get transactionFormChangeDate => 'Change';

  @override
  String transactionFormTodayDate(String date) {
    return 'Today, $date';
  }

  @override
  String get transactionFormSave => 'Save transaction';

  @override
  String get transactionFormSaveSuccess => 'Transaction saved successfully';

  @override
  String transactionFormSaveError(String error) {
    return 'Could not save transaction: $error';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get walletsSubtitle => 'Manage your cash and bank assets';

  @override
  String get walletsAddWallet => 'Add wallet';

  @override
  String get walletsSearchHint => 'Search wallets...';

  @override
  String get walletsEstimatedTotal => 'Estimated total balance';

  @override
  String get walletsMonthlyGrowth => 'Monthly growth';

  @override
  String get walletsWalletCount => 'Wallet count';

  @override
  String walletsWalletCountValue(int count) {
    return '$count wallets';
  }

  @override
  String get walletsTotalValue => 'Total value';

  @override
  String get walletsRemainingDebt => 'Remaining payment';

  @override
  String get walletsEmpty =>
      'No wallets yet.\nAdd cash, bank, or digital wallet.';

  @override
  String walletsGrowthValue(String percent) {
    return '+$percent%';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get walletFormTitleNew => 'New wallet';

  @override
  String get walletFormTitleEdit => 'Edit wallet';

  @override
  String get walletFormName => 'Wallet name';

  @override
  String get walletFormNameHint => 'e.g. Cash, Bank';

  @override
  String get walletFormNameRequired => 'Name is required';

  @override
  String get walletFormCurrency => 'Currency';

  @override
  String get walletFormSelectCurrency => 'Select a currency';

  @override
  String get walletFormOpeningBalance => 'Opening balance';

  @override
  String get walletFormBalanceRequired => 'Balance is required';

  @override
  String get walletFormInvalidNumber => 'Invalid number';

  @override
  String get walletFormIcon => 'Icon';

  @override
  String get walletFormCreate => 'Create';

  @override
  String get walletFormSave => 'Save';

  @override
  String get walletFormDeleteTitle => 'Delete wallet';

  @override
  String get walletFormDeleteMessage => 'Are you sure? This cannot be undone.';

  @override
  String walletFormError(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get treasuryIconCash => 'Cash safe';

  @override
  String get treasuryIconCashShort => 'Cash';

  @override
  String get treasuryIconBank => 'Bank';

  @override
  String get treasuryIconCrypto => 'Digital';

  @override
  String get treasuryIconTravel => 'Travel';

  @override
  String get walletFormAddTitle => 'Add wallet';

  @override
  String get walletFormAddSubtitle =>
      'Add a new financial vessel to organize your wealth';

  @override
  String get walletFormEditSubtitle => 'Edit wallet details';

  @override
  String get walletFormWalletType => 'Wallet type';

  @override
  String get walletFormNameHintNew => 'e.g. Emergency savings';

  @override
  String get walletFormAddOpeningBalance => 'Add opening balance';

  @override
  String get walletFormConfirmAdd => 'Confirm';

  @override
  String get walletFormOpeningBalanceRequired =>
      'At least one opening balance is required';

  @override
  String get walletFormDuplicateCurrency =>
      'Duplicate currency is not allowed in the same wallet';

  @override
  String get walletsEditWallet => 'Edit wallet';

  @override
  String get walletFormCurrentBalance => 'Current balance';

  @override
  String get walletFormAccountHasTransactions =>
      'Cannot remove a currency linked to transactions or transfers';

  @override
  String get walletFormNoCurrencies =>
      'No currencies found. Add a currency from settings first.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCurrencies => 'Currencies';

  @override
  String settingsBaseCurrency(String code) {
    return 'Base currency: $code';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockSubtitle =>
      'Requires PIN or biometric to enter again';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupSubtitle => 'Available in phase 8';

  @override
  String get currenciesTitle => 'Currencies';

  @override
  String get currencyDeleteTitle => 'Delete currency';

  @override
  String currencyDeleteMessage(String name, String code) {
    return 'Delete $name ($code)?';
  }

  @override
  String currencyExchangeRateBase(String code) {
    return '$code — exchange rate: 1.0';
  }

  @override
  String get currencyFormEditTitle => 'Edit currency';

  @override
  String get currencyFormNewTitle => 'New currency';

  @override
  String get currencyFormPresetHint => 'Pick from the list or enter manually';

  @override
  String get currencyFormCodeLabel => 'Currency code';

  @override
  String get currencyFormCodeHint => 'TRY';

  @override
  String get currencyFormInvalidCode => 'Invalid code';

  @override
  String get currencyFormNameLabel => 'Currency name';

  @override
  String get currencyFormNameHint => 'Turkish lira';

  @override
  String get currencyFormSymbolLabel => 'Symbol';

  @override
  String get currencyFormSymbolHint => '₺';

  @override
  String get currencyFormSymbolRequired => 'Symbol is required';

  @override
  String currencyFormRateLabel(String baseCode) {
    return 'Exchange rate vs $baseCode';
  }

  @override
  String get currencyFormRateHint => '0.025';

  @override
  String currencyFormRateHelper(String code, String baseCode) {
    return '1 $code = X $baseCode';
  }

  @override
  String get currencyFormRateRequired => 'Exchange rate is required';

  @override
  String get currencyFormPositiveNumber => 'Enter a positive number';

  @override
  String currencyFormPreview(String code, String approx) {
    return '100 $code $approx';
  }

  @override
  String get currencyFormAdd => 'Add';

  @override
  String get currencyFormSave => 'Save';

  @override
  String get dashboardRetry => 'Retry';

  @override
  String get balanceHintZero => '0.00';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get currencyBaseBadge => 'Base';

  @override
  String get currencyBaseAlreadyExists =>
      'A base currency already exists. Only one base currency is allowed.';

  @override
  String get currencyAlreadyExists => 'Currency already exists';

  @override
  String get currenciesEmpty => 'No currencies yet.';

  @override
  String get dashboardGoalsEmpty =>
      'No financial goals yet. Start by defining your first goal.';

  @override
  String get goalFormTitle => 'Add goal';

  @override
  String get goalFormHeading => 'Your next step';

  @override
  String get goalFormSubtitle =>
      'Clearly define the shape of your financial future';

  @override
  String get goalFormName => 'What is your goal?';

  @override
  String get goalFormNameHint => 'e.g. buying your dream car';

  @override
  String get goalFormNameRequired => 'Goal name is required';

  @override
  String get goalFormTargetAmount => 'Target amount';

  @override
  String get goalFormSavedAmount => 'Amount already saved';

  @override
  String get goalFormAmountRequired => 'Amount is required';

  @override
  String get goalFormInvalidAmount => 'Enter a valid amount';

  @override
  String get goalFormSavedExceedsTarget =>
      'Saved amount cannot exceed the target amount';

  @override
  String get goalFormTargetDate => 'Expected completion date';

  @override
  String get goalFormDateHint => 'mm/dd/yyyy';

  @override
  String get goalFormDateRequired => 'Select an expected completion date';

  @override
  String get goalFormChooseIcon => 'Choose an icon for the goal';

  @override
  String get goalFormSelectCurrency => 'Select a currency';

  @override
  String get goalFormSave => 'Save financial goal';

  @override
  String get goalPlanTitle => 'Suggested plan';

  @override
  String get goalPlanIntro => 'Based on your goal, we suggest:';

  @override
  String goalPlanMonthlyAmount(String amount) {
    return 'Save $amount / month';
  }

  @override
  String goalPlanReachDate(String date) {
    return 'You will reach your goal in $date';
  }

  @override
  String get goalPlanWarningLargeAmount =>
      'The required monthly amount exceeds 50% of your monthly income. Consider extending the timeline or lowering the target.';

  @override
  String get goalPlanWarningUnrealisticDate =>
      'The target date may not be realistic based on your income and spending. Try adjusting the date or amount.';

  @override
  String get goalPlanAccept => 'Accept plan';

  @override
  String get goalPlanEdit => 'Edit';

  @override
  String get goalPlanCompare => 'Compare';

  @override
  String get goalPlanCompareTitle => 'Compare plans';

  @override
  String get goalPlanCompareTargetDate => 'Based on your target date';

  @override
  String get goalPlanCompareComfortable => 'Comfortable plan';

  @override
  String get goalPlanCompareExtended => 'Extended plan';

  @override
  String get goalPlanCompareMonthly => 'Monthly savings';

  @override
  String get goalPlanCompareDate => 'Reach date';

  @override
  String get goalPlanCompareRecommended => 'Best fit';

  @override
  String goalPlanSaveError(String error) {
    return 'Could not save goal: $error';
  }

  @override
  String get goalEditTitle => 'Edit goal';

  @override
  String get goalEditHeading => 'Your goal progress';

  @override
  String get goalEditSubtitle =>
      'Update your financial goal and track your progress';

  @override
  String goalEditProgress(int percent) {
    return '$percent% complete';
  }

  @override
  String goalEditSavedOfTarget(String saved, String target) {
    return 'Saved $saved of $target';
  }

  @override
  String get goalEditSave => 'Save changes';

  @override
  String get goalEditNotFound => 'Goal not found';

  @override
  String goalEditSaveError(String error) {
    return 'Could not save changes: $error';
  }

  @override
  String get goalEditDeleteTitle => 'Delete goal';

  @override
  String get goalEditDeleteMessage =>
      'Are you sure you want to delete this goal? This cannot be undone.';

  @override
  String goalEditDeleteError(String error) {
    return 'Could not delete goal: $error';
  }
}
