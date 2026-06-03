import 'package:intl/intl.dart';

/// Formats monetary amounts for display.
abstract final class CurrencyFormatter {
  static String format(double amount, {String symbol = '', int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'en_US');
    final formatted = formatter.format(amount);
    if (symbol.isEmpty) return formatted;
    return '$formatted $symbol';
  }

  static String formatWithCode(double amount, String code, {int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'en_US');
    return '${formatter.format(amount)} $code';
  }

  /// Formats as `USD 1,250.00` (code before amount) for dashboard display.
  static String formatCodeFirst(double amount, String code, {int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'en_US');
    return '$code ${formatter.format(amount)}';
  }

  /// Formats numeric part only, e.g. `1,250.00`.
  static String formatAmountOnly(double amount, {int decimals = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'en_US');
    return formatter.format(amount);
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
