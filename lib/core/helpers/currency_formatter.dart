import '../../models/amount_format_style.dart';
import 'number_format_preferences.dart';

/// Formats monetary amounts for display using [NumberFormatPreferences].
abstract final class CurrencyFormatter {
  static NumberFormatPreferences get _prefs => NumberFormatPreferences.current;

  /// Applies user number-format settings (call on startup and when settings change).
  static void configureFromStyle(AmountFormatStyle style) {
    NumberFormatPreferences.configure(style);
  }

  static String format(double amount, {String symbol = '', int decimals = 2}) {
    final formatted = _prefs.formatAmount(
      amount,
      minDecimals: decimals,
      maxDecimals: decimals,
    );
    if (symbol.isEmpty) return formatted;
    return '$formatted $symbol';
  }

  static String formatWithCode(double amount, String code, {int decimals = 2}) {
    return '${_prefs.formatAmount(amount, minDecimals: decimals, maxDecimals: decimals)} $code';
  }

  /// Formats as `USD 1,250.00` (code before amount) for dashboard display.
  static String formatCodeFirst(double amount, String code, {int decimals = 2}) {
    return '$code ${_prefs.formatAmount(amount, minDecimals: decimals, maxDecimals: decimals)}';
  }

  /// Formats numeric part only, e.g. `1,250.00`.
  static String formatAmountOnly(double amount, {int decimals = 2}) {
    return _prefs.formatAmount(
      amount,
      minDecimals: decimals,
      maxDecimals: decimals,
    );
  }

  /// Converts amount from one currency to base using exchange rate.
  static double toBaseAmount(double amount, double rateToBase) {
    return amount * rateToBase;
  }

  /// Shows approximate base currency equivalent before saving.
  static String approximateBase(
    double amount,
    double rateToBase,
    String baseCode,
  ) {
    final baseAmount = toBaseAmount(amount, rateToBase);
    return '≈ ${formatWithCode(baseAmount, baseCode)}';
  }
}
