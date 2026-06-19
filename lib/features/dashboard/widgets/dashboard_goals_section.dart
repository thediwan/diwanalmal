import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/clay_card.dart';
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
                    color: Theme.of(context).colorScheme.primary,
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

    return ClayCard(
      elevation: ClayElevation.low,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.track_changes_rounded,
            size: 36,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.40),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onAddGoal,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatefulWidget {
  const _GoalCard({
    required this.goal,
    required this.onTap,
  });

  final DashboardGoal goal;
  final VoidCallback onTap;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.emphasized,
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.goal.progressPercent / 100.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.easeEmphasized,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppMotion.shouldAnimate(context)) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isComplete = widget.goal.progressPercent >= 100;
    final progressColor =
        isComplete ? AppColors.success : Theme.of(context).colorScheme.primary;

    return ClayCard(
      elevation: ClayElevation.standard,
      padding: const EdgeInsets.all(16),
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.iconBadge),
                ),
                child: Icon(
                  widget.goal.icon,
                  color: progressColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.goal.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${widget.goal.progressPercent}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) {
              final value = AppMotion.shouldAnimate(context)
                  ? _progressAnim.value
                  : widget.goal.progressPercent / 100.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: colors.divider,
                    color: progressColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
