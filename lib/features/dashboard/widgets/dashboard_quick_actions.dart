import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';

/// Three quick-action buttons below the balance hero card.
///
/// Actions: Add Transaction / Transfer / View All
/// Each button has a clay-chip container with icon micro-bounce on tap.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionButton(
            icon: CupertinoIcons.plus_circle_fill,
            label: l10n.quickActionAddTransaction,
            onTap: () => context.push('/transactions/add?type=expense'),
          ),
          _QuickActionButton(
            icon: CupertinoIcons.arrow_right_arrow_left_circle_fill,
            label: l10n.quickActionTransfer,
            onTap: () => context.push('/transactions/add?type=transfer'),
          ),
          _QuickActionButton(
            icon: CupertinoIcons.list_bullet,
            label: l10n.quickActionViewAll,
            onTap: () => context.go('/transactions'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.micro,
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.easeStandard,
        reverseCurve: AppMotion.easeSpring,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (AppMotion.shouldAnimate(context)) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (AppMotion.shouldAnimate(context)) _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    if (AppMotion.shouldAnimate(context)) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: 92,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? primary.withValues(alpha: 0.10)
                      : primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.iconBadge + 2),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  widget.icon,
                  size: 26,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
