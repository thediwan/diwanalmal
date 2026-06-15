import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';

/// Expense / income segmented control for transaction entry.
class TransactionTypeToggle extends StatelessWidget {
  const TransactionTypeToggle({
    super.key,
    required this.isExpense,
    required this.expenseLabel,
    required this.incomeLabel,
    required this.onChanged,
  });

  final bool isExpense;
  final String expenseLabel;
  final String incomeLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: expenseLabel,
              selected: isExpense,
              selectedColor: AppColors.expense,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: incomeLabel,
              selected: !isExpense,
              selectedColor: AppColors.success,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: selected ? selectedColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? colors.onPrimary : colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
