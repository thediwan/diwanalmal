import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/transaction_entry_type.dart';

/// Segmented control for transaction entry modes (scrollable when crowded).
class TransactionTypeToggle extends StatelessWidget {
  const TransactionTypeToggle({
    super.key,
    required this.selected,
    required this.expenseLabel,
    required this.incomeLabel,
    required this.transferLabel,
    required this.debtorLabel,
    required this.creditorLabel,
    required this.onChanged,
  });

  final TransactionEntryType selected;
  final String expenseLabel;
  final String incomeLabel;
  final String transferLabel;
  final String debtorLabel;
  final String creditorLabel;
  final ValueChanged<TransactionEntryType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          children: [
            _SegmentButton(
              label: expenseLabel,
              selected: selected == TransactionEntryType.expense,
              selectedColor: AppColors.expense,
              onTap: () => onChanged(TransactionEntryType.expense),
            ),
            _SegmentButton(
              label: incomeLabel,
              selected: selected == TransactionEntryType.income,
              selectedColor: AppColors.success,
              onTap: () => onChanged(TransactionEntryType.income),
            ),
            _SegmentButton(
              label: transferLabel,
              selected: selected == TransactionEntryType.currencyTransfer,
              selectedColor: Theme.of(context).colorScheme.primary,
              onTap: () => onChanged(TransactionEntryType.currencyTransfer),
            ),
            _SegmentButton(
              label: debtorLabel,
              selected: selected == TransactionEntryType.debtor,
              selectedColor: AppColors.success,
              onTap: () => onChanged(TransactionEntryType.debtor),
            ),
            _SegmentButton(
              label: creditorLabel,
              selected: selected == TransactionEntryType.creditor,
              selectedColor: AppColors.debtAccent,
              onTap: () => onChanged(TransactionEntryType.creditor),
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? colors.onPrimary : colors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
