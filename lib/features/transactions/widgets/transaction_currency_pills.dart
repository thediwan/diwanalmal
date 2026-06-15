import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/currency.dart';

/// Horizontal currency pill selector.
class TransactionCurrencyPills extends StatelessWidget {
  const TransactionCurrencyPills({
    super.key,
    required this.currencies,
    required this.selectedCurrencyId,
    required this.onSelected,
  });

  final List<Currency> currencies;
  final String? selectedCurrencyId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (currencies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: currencies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final selected = currency.id == selectedCurrencyId;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(currency.id),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? colors.surface : colors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.dashboardPrimary
                        : colors.cardBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  currency.code,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selected
                        ? AppColors.dashboardPrimary
                        : colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
