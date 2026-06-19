import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/clay_card.dart';

/// Progress summary shown above the goal edit form.
///
/// Features animated progress bar draw on first render and a goal-achieved
/// celebration state when [progressPercent] >= 100.
class GoalProgressHeader extends StatefulWidget {
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
  State<GoalProgressHeader> createState() => _GoalProgressHeaderState();
}

class _GoalProgressHeaderState extends State<GoalProgressHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.emphasized,
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: (widget.progressPercent / 100.0).clamp(0.0, 1.0),
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
  void didUpdateWidget(GoalProgressHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressPercent != widget.progressPercent) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: (widget.progressPercent / 100.0).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppMotion.easeEmphasized,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final isComplete = widget.progressPercent >= 100;
    final accentColor = isComplete ? AppColors.success : Theme.of(context).colorScheme.primary;

    return ClayCard(
      elevation: ClayElevation.standard,
      padding: const EdgeInsets.all(20),
      gradient: isComplete
          ? LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.success.withValues(alpha: 0.12),
                AppColors.success.withValues(alpha: 0.04),
              ],
            )
          : null,
      child: Column(
        children: [
          // Icon badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.emoji_events_rounded : widget.icon,
              color: accentColor,
              size: 30,
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: 10),
            Text(
              l10n.goalAchievedTitle,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.goalAchievedSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Animated progress label (count-up)
          TweenAnimationBuilder<int>(
            tween: IntTween(
              begin: 0,
              end: widget.progressPercent.clamp(0, 100),
            ),
            duration: AppMotion.shouldAnimate(context)
                ? AppMotion.emphasized
                : Duration.zero,
            curve: AppMotion.easeEmphasized,
            builder: (context, value, _) => Text(
              '$value%',
              style: AppTextStyles.headingSmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.savedOfTargetLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          // Animated progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) {
              final value = AppMotion.shouldAnimate(context)
                  ? _progressAnim.value
                  : widget.progressPercent / 100.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: colors.divider,
                    color: accentColor,
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
