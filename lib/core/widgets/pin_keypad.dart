import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../extensions/context_theme.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';

/// Clay-style numeric keypad for PIN entry.
///
/// Each key press triggers a press deformation animation (scale + shadow
/// collapse) with spring release. Respects [MediaQueryData.disableAnimations].
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key.isEmpty) return const SizedBox.shrink();

        return _ClayKey(
          label: key,
          onTap: () {
            if (key == '⌫') {
              onBackspace();
            } else {
              onDigit(key);
            }
          },
        );
      },
    );
  }
}

class _ClayKey extends StatefulWidget {
  const _ClayKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ClayKey> createState() => _ClayKeyState();
}

class _ClayKeyState extends State<_ClayKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.micro,
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: AppMotion.pressScaleButton).animate(
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
    HapticFeedback.lightImpact();
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
    final isBackspace = widget.label == '⌫';

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.surfaceElevatedLight,
            borderRadius: AppRadius.cardBorderRadius,
            boxShadow: isDark ? AppShadow.clayDark : AppShadow.clayLight,
          ),
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace_outlined,
                    size: 22,
                    color: colors.textSecondary,
                  )
                : Text(
                    widget.label,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN dots indicator with shake animation for wrong PIN
// ---------------------------------------------------------------------------

/// Visual PIN dots indicator.
///
/// Call [PinDotsController.shake] (via a [GlobalKey]) to trigger the shake
/// animation when the user enters a wrong PIN.
class PinDots extends StatefulWidget {
  const PinDots({
    super.key,
    required this.length,
    this.maxLength = 4,
    this.hasError = false,
  });

  final int length;
  final int maxLength;

  /// When true, dots turn red and a shake animation plays once.
  final bool hasError;

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(PinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasError && widget.hasError) {
      if (AppMotion.shouldAnimate(context)) {
        _shakeController
          ..reset()
          ..forward();
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.maxLength, (index) {
          final filled = index < widget.length;
          final dotColor = widget.hasError
              ? AppColors.expense
              : filled
                  ? primary
                  : colors.textMuted.withValues(alpha: 0.30);

          return AnimatedContainer(
            duration: AppMotion.micro,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: filled ? 16 : 14,
            height: filled ? 16 : 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: filled && !widget.hasError && !isDark
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
