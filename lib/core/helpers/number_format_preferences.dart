import 'package:intl/intl.dart';

import '../../models/amount_format_style.dart';

/// User-configurable number formatting (stored in Hive, UI in settings later).
class NumberFormatPreferences {
  const NumberFormatPreferences({this.style = AmountFormatStyle.western});

  final AmountFormatStyle style;

  static const NumberFormatPreferences defaults = NumberFormatPreferences();

  static NumberFormatPreferences _current = defaults;

  /// Active preferences for formatters and amount input display.
  static NumberFormatPreferences get current => _current;

  static void configure(AmountFormatStyle style) {
    _current = NumberFormatPreferences(style: style);
  }

  String get thousandsSeparator => switch (style) {
        AmountFormatStyle.western => ',',
        AmountFormatStyle.european => '.',
        AmountFormatStyle.plain => '',
      };

  String get decimalSeparator => switch (style) {
        AmountFormatStyle.western => '.',
        AmountFormatStyle.european => ',',
        AmountFormatStyle.plain => '.',
      };

  /// Builds an [NumberFormat] for fixed decimal places (e.g. currency lists).
  NumberFormat fixedDecimalsFormatter({int decimals = 2}) {
    final fraction = '0' * decimals;
    return switch (style) {
      AmountFormatStyle.western =>
        NumberFormat('#,##0.$fraction', 'en_US'),
      AmountFormatStyle.european =>
        NumberFormat('#,##0.$fraction', 'de_DE'),
      AmountFormatStyle.plain => NumberFormat('#0.$fraction', 'en_US'),
    };
  }

  /// Formats [amount] with up to [maxDecimals] fraction digits; trims trailing
  /// zeros when [minDecimals] is lower.
  String formatAmount(
    double amount, {
    int minDecimals = 0,
    int maxDecimals = 2,
  }) {
    final formatter = fixedDecimalsFormatter(decimals: maxDecimals);
    formatter.minimumFractionDigits = minDecimals;
    formatter.maximumFractionDigits = maxDecimals;
    return formatter.format(amount);
  }
}
