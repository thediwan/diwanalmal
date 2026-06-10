import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    this.onAddGoal,
    this.onGoalTap,
  });

  final List<DashboardGoal> goals;
  final VoidCallback? onAddGoal;
  final ValueChanged<String>? onGoalTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

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
                onPressed: onAddGoal ?? () => context.push('/goals/add'),
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
          if (goals.isEmpty)
            _EmptyGoalsCard(
              message: l10n.dashboardGoalsEmpty,
              actionLabel: l10n.dashboardAddGoal,
              onAddGoal: onAddGoal ?? () => context.push('/goals/add'),
            )
          else
            ...goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GoalCard(
                  goal: goal,
                  onTap: onGoalTap != null
                      ? () => onGoalTap!(goal.id)
                      : () => context.push('/goals/${goal.id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyGoalsCard extends StatelessWidget {
  const _EmptyGoalsCard({
    required this.message,
    required this.actionLabel,
    required this.onAddGoal,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAddGoal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onAddGoal,
            child: Text(
              actionLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.dashboardPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onTap,
  });

  final DashboardGoal goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
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
        ),
      ),
    );
  }
}
