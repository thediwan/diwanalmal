import 'package:flutter/material.dart';

import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';

/// Total balance line: muted currency code + large amount (mockup style).
class DashboardTotalBalance extends StatelessWidget {
  const DashboardTotalBalance({
    super.key,
    required this.label,
    required this.amount,
    required this.currencyCode,
  });

  final String label;
  final double amount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelOnSurface(colors).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currencyCode ',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Text(
                CurrencyFormatter.formatAmountOnly(amount),
                style: AppTextStyles.headingLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 36,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
