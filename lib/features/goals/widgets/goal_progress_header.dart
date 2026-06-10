import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';

/// Progress summary shown above the goal edit form.
class GoalProgressHeader extends StatelessWidget {
  const GoalProgressHeader({
    super.key,
    required this.icon,
    required this.progressPercent,
    required this.savedAmount,
    required this.targetAmount,
    required this.currencySymbol,
    required this.progressLabel,
    required this.savedOfTargetLabel,
  });

  final IconData icon;
  final int progressPercent;
  final double savedAmount;
  final double targetAmount;
  final String currencySymbol;
  final String progressLabel;
  final String savedOfTargetLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.dashboardPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.dashboardPrimary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            progressLabel,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.dashboardPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            savedOfTargetLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 12,
                backgroundColor: colors.divider,
                color: AppColors.dashboardPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
