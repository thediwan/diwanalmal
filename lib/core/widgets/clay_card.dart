import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../theme/app_motion.dart';

/// Clay card elevation levels — controls shadow depth and surface tinting.
enum ClayElevation {
  /// Subtle ambient-only shadow for list items and secondary cards.
  low,

  /// Standard clay card — balanced ambient + sky-tinted glow.
  standard,

  /// Hero card for balance display, primary CTAs, gradient surfaces.
  hero,
}

/// Tactile clay surface widget — the primary card container for ديوان المال.
///
/// Provides:
/// - Sky-tinted layered shadows (no border lines)
/// - Press deformation (scale + shadow collapse) with spring release
/// - Three elevation levels: low / standard / hero
/// - Respects [MediaQueryData.disableAnimations] for accessibility
///
/// Usage:
/// ```dart
/// ClayCard(
///   onTap: () {},
///   child: Text('Hello'),
/// )
/// ```
///
/// For gradient hero cards (e.g. balance display), provide [gradient] instead
/// of relying on the default [surfaceElevated] background.
class ClayCard extends StatefulWidget {
  const ClayCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation = ClayElevation.standard,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ClayElevation elevation;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  /// Optional gradient — overrides [backgroundColor].
  final Gradient? gradient;

  /// Override background color. Defaults to [AppThemeColors.surfaceElevated].
  final Color? backgroundColor;

  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  State<ClayCard> createState() => _ClayCardState();
}

class _ClayCardState extends State<ClayCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.micro,
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.elevation == ClayElevation.hero
          ? AppMotion.pressScale
          : AppMotion.pressScaleButton,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.easeStandard,
      reverseCurve: AppMotion.easeSpring,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!AppMotion.shouldAnimate(context)) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!AppMotion.shouldAnimate(context)) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!AppMotion.shouldAnimate(context)) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark
        ? AppColors.surfaceElevatedDark
        : AppColors.surfaceElevatedLight;

    final shadows = _resolveShadows(isDark);
    final radius = widget.borderRadius ??
        (widget.elevation == ClayElevation.hero
            ? AppRadius.cardLargeBorderRadius
            : AppRadius.cardBorderRadius);

    final container = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: widget.gradient == null
            ? (widget.backgroundColor ?? defaultBg)
            : null,
        gradient: widget.gradient,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: widget.clipBehavior,
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null && widget.onLongPress == null) {
      return container;
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: container,
      ),
    );
  }

  List<BoxShadow> _resolveShadows(bool isDark) {
    // Pressed state — only ambient
    if (_controller.isAnimating || _controller.value > 0) {
      return isDark ? AppShadow.clayPressedDark : AppShadow.clayPressedLight;
    }

    switch (widget.elevation) {
      case ClayElevation.low:
        return isDark
            ? [AppShadow.clayDark.first]
            : [AppShadow.clayLight.first];
      case ClayElevation.standard:
        return isDark ? AppShadow.clayDark : AppShadow.clayLight;
      case ClayElevation.hero:
        return isDark ? AppShadow.clayHeroDark : AppShadow.clayHeroLight;
    }
  }
}

// ---------------------------------------------------------------------------
// Skeleton shimmer loader — same shape as ClayCard, used while data loads.
// ---------------------------------------------------------------------------

/// Animated shimmer placeholder matching a clay card surface.
class ClayCardSkeleton extends StatefulWidget {
  const ClayCardSkeleton({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
  });

  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<ClayCardSkeleton> createState() => _ClayCardSkeletonState();
}

class _ClayCardSkeletonState extends State<ClayCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (AppMotion.shouldAnimate(context)) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.surfaceElevatedDark
        : AppColors.surfaceElevatedLight;
    final shimmerColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Padding(
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius:
                  widget.borderRadius ?? AppRadius.cardBorderRadius,
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  baseColor,
                  shimmerColor,
                  baseColor,
                ],
                stops: [
                  (_controller.value - 0.3).clamp(0.0, 1.0),
                  _controller.value.clamp(0.0, 1.0),
                  (_controller.value + 0.3).clamp(0.0, 1.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
