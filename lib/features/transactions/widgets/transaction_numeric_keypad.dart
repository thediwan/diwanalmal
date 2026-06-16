import 'package:flutter/material.dart';

import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';

/// Calculator-style numeric keypad for transaction amounts (cents-based).
class TransactionNumericKeypad extends StatelessWidget {
  const TransactionNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
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
                onTap: () {
                  onDigit(0);
                  onDigit(0);
                },
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

/// Tracks amount entry in minor units (cents) for keypad input.
class TransactionAmountInput {
  TransactionAmountInput();

  int _minorUnits = 0;

  double get value => _minorUnits / 100;

  String get display => value.toStringAsFixed(2);

  void appendDigit(int digit) {
    if (digit < 0 || digit > 9) return;
    final next = _minorUnits * 10 + digit;
    if (next > 99999999999) return;
    _minorUnits = next;
  }

  void backspace() {
    _minorUnits ~/= 10;
  }

  void reset() {
    _minorUnits = 0;
  }

  /// Sets amount from an existing record (edit screen).
  void setValue(double amount) {
    _minorUnits = (amount * 100).round();
  }
}
