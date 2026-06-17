import 'package:flutter/material.dart';

import '../../../core/helpers/number_format_preferences.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';

/// Calculator-style numeric keypad for transaction amounts.
class TransactionNumericKeypad extends StatelessWidget {
  const TransactionNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onDoubleZero,
    required this.onBackspace,
    this.decimalLabel,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onDoubleZero;
  final VoidCallback onBackspace;

  /// Label for the decimal key; defaults to user number-format preference.
  final String? decimalLabel;

  @override
  Widget build(BuildContext context) {
    final decimalKey =
        decimalLabel ?? NumberFormatPreferences.current.decimalSeparator;

    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (final digit in row) ...[
                  Expanded(child: _KeyButton(label: '$digit', onTap: () => onDigit(digit))),
                  if (digit != row.last) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _KeyButton(
                label: '00',
                onTap: onDoubleZero,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KeyButton(
                label: decimalKey,
                onTap: onDecimal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _KeyButton(label: '0', onTap: () => onDigit(0))),
            const SizedBox(width: 10),
            Expanded(
              child: _KeyButton(
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.cardBorder),
          ),
          child: icon != null
              ? Icon(icon, color: colors.textPrimary, size: 22)
              : Text(
                  label!,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Keypad-driven amount entry in whole currency units (not cents).
class TransactionAmountInput {
  TransactionAmountInput();

  String _whole = '';
  String _fraction = '';
  bool _editingFraction = false;

  static const int _maxWholeDigits = 9;
  static const int _maxFractionDigits = 2;

  double get value {
    if (_whole.isEmpty && _fraction.isEmpty && !_editingFraction) {
      return 0;
    }
    final wholeText = _whole.isEmpty ? '0' : _whole;
    if (!_editingFraction && _fraction.isEmpty) {
      return double.tryParse(wholeText) ?? 0;
    }
    final fractionText = _fraction.padRight(_maxFractionDigits, '0');
    return double.tryParse('$wholeText.$fractionText') ?? 0;
  }

  /// Live display while typing (respects user decimal separator).
  String get display {
    final decimalSep = NumberFormatPreferences.current.decimalSeparator;
    if (_whole.isEmpty && !_editingFraction) return '0';
    final wholeText = _whole.isEmpty ? '0' : _whole;
    if (!_editingFraction) return wholeText;
    if (_fraction.isEmpty) return '$wholeText$decimalSep';
    return '$wholeText$decimalSep$_fraction';
  }

  void appendDigit(int digit) {
    if (digit < 0 || digit > 9) return;
    if (_editingFraction) {
      if (_fraction.length >= _maxFractionDigits) return;
      _fraction += '$digit';
      return;
    }
    if (_whole == '0') {
      if (digit == 0) return;
      _whole = '$digit';
      return;
    }
    if (_whole.length >= _maxWholeDigits) return;
    _whole += '$digit';
  }

  /// Appends `00` to the whole part, or completes the fraction when active.
  void appendDoubleZero() {
    if (_editingFraction) {
      if (_fraction.length >= _maxFractionDigits) return;
      if (_fraction.isEmpty) {
        _fraction = '00';
        return;
      }
      if (_fraction.length == 1) {
        _fraction += '0';
      }
      return;
    }
    if (_whole.isEmpty) {
      _whole = '0';
      return;
    }
    if (_whole.length > _maxWholeDigits - 2) return;
    _whole += '00';
  }

  void startDecimal() {
    if (_editingFraction) return;
    _editingFraction = true;
    if (_whole.isEmpty) _whole = '0';
  }

  void backspace() {
    if (_editingFraction) {
      if (_fraction.isNotEmpty) {
        _fraction = _fraction.substring(0, _fraction.length - 1);
        return;
      }
      _editingFraction = false;
      return;
    }
    if (_whole.isNotEmpty) {
      _whole = _whole.substring(0, _whole.length - 1);
    }
  }

  void reset() {
    _whole = '';
    _fraction = '';
    _editingFraction = false;
  }

  /// Sets amount from an existing record (edit screen).
  void setValue(double amount) {
    _whole = '';
    _fraction = '';
    _editingFraction = false;
    if (amount == 0) return;

    final text = _amountToInputString(amount);
    if (!text.contains('.')) {
      _whole = text;
      return;
    }
    final parts = text.split('.');
    _whole = parts[0];
    _fraction = parts[1];
    _editingFraction = true;
  }

  static String _amountToInputString(double amount) {
    var text = amount.toString();
    if (text.contains('.')) {
      text = text.replaceAll(RegExp(r'0+$'), '');
      text = text.replaceAll(RegExp(r'\.$'), '');
    }
    return text;
  }
}
