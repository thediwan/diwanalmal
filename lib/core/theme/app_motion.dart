import 'package:flutter/material.dart';

/// Motion design tokens for ديوان المال.
///
/// Every animation must answer: "What financial event just happened?"
/// Motion communicates trust, confirmation, risk, and success.
///
/// Always guard with [AppMotion.shouldAnimate] to respect
/// [MediaQueryData.disableAnimations] / prefers-reduced-motion.
abstract final class AppMotion {
  // ---------------------------------------------------------------------------
  // Duration tokens
  // ---------------------------------------------------------------------------

  /// Button press, chip select, icon swap — instant feedback.
  static const Duration micro = Duration(milliseconds: 150);

  /// Card expand/collapse, sheet slide, tab switch — standard transitions.
  static const Duration standard = Duration(milliseconds: 250);

  /// Balance update, goal completion, success morph — emphasized moments.
  static const Duration emphasized = Duration(milliseconds: 400);

  /// Page / route transitions.
  static const Duration page = Duration(milliseconds: 300);

  /// Stagger offset between list items (multiply by index).
  static const Duration staggerItem = Duration(milliseconds: 30);

  /// Max stagger cap (do not stagger beyond 5 visible items).
  static const Duration staggerMax = Duration(milliseconds: 150);

  // ---------------------------------------------------------------------------
  // Easing curves
  // ---------------------------------------------------------------------------

  /// Entering elements — ease out feels natural for items arriving.
  static const Curve easeEnter = Curves.easeOut;

  /// Exiting elements — ease in feels natural for items leaving.
  static const Curve easeExit = Curves.easeIn;

  /// State changes within the same context.
  static const Curve easeStandard = Curves.easeInOut;

  /// Emphasized moments — slight spring, not bouncy.
  static const Curve easeEmphasized = Curves.fastOutSlowIn;

  /// Spring physics for press-release interactions.
  static const Curve easeSpring = Curves.elasticOut;

  /// Page transitions.
  static const Curve easePage = Curves.fastOutSlowIn;

  // ---------------------------------------------------------------------------
  // Interaction scale tokens
  // ---------------------------------------------------------------------------

  /// Scale on tap/press for interactive cards.
  static const double pressScale = 0.97;

  /// Scale on tap/press for small buttons / keypad keys.
  static const double pressScaleButton = 0.93;

  // ---------------------------------------------------------------------------
  // Reduced-motion guard
  // ---------------------------------------------------------------------------

  /// Returns [true] when animations should play.
  /// Returns [false] when the user has requested reduced motion.
  static bool shouldAnimate(BuildContext context) {
    return !MediaQuery.of(context).disableAnimations;
  }

  /// Returns the duration if animations are enabled, else [Duration.zero].
  static Duration guardedDuration(BuildContext context, Duration duration) {
    return shouldAnimate(context) ? duration : Duration.zero;
  }
}
