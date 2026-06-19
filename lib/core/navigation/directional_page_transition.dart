import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

/// RTL-aware slide transition for GoRouter custom page transitions.
///
/// When the locale is RTL (Arabic), forward navigation slides in from the
/// leading edge (left in RTL → right in LTR). Reverse navigation slides out
/// to the trailing edge.
///
/// Usage in GoRouter:
/// ```dart
/// GoRoute(
///   path: '/somewhere',
///   pageBuilder: (context, state) => DirectionalPageTransition.buildPage(
///     context: context,
///     state: state,
///     child: const SomeScreen(),
///   ),
/// )
/// ```
abstract final class DirectionalPageTransition {
  /// Builds a [CustomTransitionPage] with RTL-aware slide + fade.
  static CustomTransitionPage<T> buildPage<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: AppMotion.page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(context, animation, secondaryAnimation, child);
      },
    );
  }

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Forward: slide in from the trailing edge in RTL (right side in LTR)
    // In RTL, "next screen" comes from the right, which is the start in LTR terms
    final beginOffset = isRtl
        ? const Offset(-0.08, 0) // Arabic: slide from left (trailing in RTL)
        : const Offset(0.08, 0); // LTR: slide from right

    final enterTween = Tween(begin: beginOffset, end: Offset.zero).chain(
      CurveTween(curve: AppMotion.easePage),
    );
    final exitTween =
        Tween(begin: Offset.zero, end: isRtl ? const Offset(0.04, 0) : const Offset(-0.04, 0))
            .chain(CurveTween(curve: AppMotion.easePage));

    final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: AppMotion.easeEnter));

    return SlideTransition(
      position: exitTween.animate(secondaryAnimation),
      child: FadeTransition(
        opacity: fadeTween.animate(animation),
        child: SlideTransition(
          position: enterTween.animate(animation),
          child: child,
        ),
      ),
    );
  }
}

/// Mixin-style extension for applying [DirectionalPageTransition] to any route.
extension GoRoutePageTransition on BuildContext {
  /// Builds a directional page with RTL-aware slide transition.
  CustomTransitionPage<T> directionalPage<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return DirectionalPageTransition.buildPage<T>(
      context: this,
      state: state,
      child: child,
    );
  }
}
