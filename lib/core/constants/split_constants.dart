/// Transaction split distribution modes.
abstract final class SplitConstants {
  static const String modeEqual = 'equal';
  static const String modePercent = 'percent';
  static const String modeFixedAmount = 'fixed_amount';

  static bool isValidMode(String mode) =>
      mode == modeEqual || mode == modePercent || mode == modeFixedAmount;
}
