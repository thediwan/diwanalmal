// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bayt Al-Mal';

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
      '© 2024 Bayt Al-Mal Financial Services. All rights reserved.';

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
      'Warning: Never share this code. Bayt Al-Mal staff will never ask for it.';

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
  String get comingSoon => 'Coming soon';
}
