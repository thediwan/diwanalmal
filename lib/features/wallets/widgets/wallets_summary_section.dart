import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/wallets_display_service.dart';

/// Summary: estimated total (no card) + growth and count metrics.
class WalletsSummarySection extends StatelessWidget {
  const WalletsSummarySection({
    super.key,
    required this.summary,
  });

  final WalletsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = CurrencyFormatter.formatAmountOnly(summary.positiveTotalInBase);
    final growth = summary.monthlyGrowthPercent.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        children: [
          Text(
            l10n.walletsEstimatedTotal,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r'$' '$total',
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.dashboardPrimary,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: l10n.walletsMonthlyGrowth,
                  value: l10n.walletsGrowthValue(growth),
                  valueColor: AppColors.success,
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: l10n.walletsWalletCount,
                  value: l10n.walletsWalletCountValue(summary.walletCount),
                  valueColor: AppColors.dashboardPrimary,
                  backgroundColor:
                      AppColors.dashboardPrimary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.backgroundColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
