import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/dashboard_models.dart';

/// Financial goals block — title right, add-goal link left (RTL mockup).
class DashboardGoalsSection extends StatelessWidget {
  const DashboardGoalsSection({
    super.key,
    required this.goals,
  });

  final List<DashboardGoal> goals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    if (goals.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.dashboardFinancialGoals,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.dashboardAddGoal,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.dashboardPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...goals.map((goal) => _GoalCard(goal: goal)),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final DashboardGoal goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              goal.icon,
              color: AppColors.dashboardPrimary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                goal.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              '${goal.progressPercent}%',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dashboardPrimary,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: LinearProgressIndicator(
              value: goal.progressPercent / 100,
              minHeight: 10,
              backgroundColor: colors.divider,
              color: AppColors.dashboardPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
