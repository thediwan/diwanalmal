import 'package:flutter/material.dart';

/// Common currency presets shown during onboarding and currency setup.
abstract final class AppConstants {
  static const String appName = 'ديوان المال';

  static const List<Map<String, String>> presetCurrencies = [
    {'code': 'USD', 'name': 'دولار أمريكي', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'يورو', 'symbol': '€'},
    {'code': 'TRY', 'name': 'ليرة تركية', 'symbol': '₺'},
    {'code': 'SYP', 'name': 'ليرة سورية', 'symbol': 'ل.س'},
    {'code': 'SAR', 'name': 'ريال سعودي', 'symbol': 'ر.س'},
    {'code': 'AED', 'name': 'درهم إماراتي', 'symbol': 'د.إ'},
    {'code': 'EGP', 'name': 'جنيه مصري', 'symbol': 'ج.م'},
    {'code': 'GBP', 'name': 'جنيه إسترليني', 'symbol': '£'},
  ];
}

// ---------------------------------------------------------------------------
// Shape radius tokens — Claymorphism-lite system
// ---------------------------------------------------------------------------

abstract final class AppRadius {
  /// Standard clay card surface.
  static const double card = 20.0;

  /// Hero/primary clay cards (balance, goal achievement).
  static const double cardLarge = 24.0;

  /// Buttons and action chips.
  static const double button = 14.0;

  /// Status chips, tag pills.
  static const double chip = 10.0;

  /// Form inputs and search fields.
  static const double input = 14.0;

  /// Bottom sheets (top corners only).
  static const double bottomSheet = 28.0;

  /// Small icon containers / avatar badges.
  static const double iconBadge = 12.0;

  static BorderRadius get cardBorderRadius =>
      BorderRadius.circular(card);

  static BorderRadius get cardLargeBorderRadius =>
      BorderRadius.circular(cardLarge);

  static BorderRadius get buttonBorderRadius =>
      BorderRadius.circular(button);

  static BorderRadius get inputBorderRadius =>
      BorderRadius.circular(input);

  static BorderRadius get bottomSheetBorderRadius => const BorderRadius.only(
        topLeft: Radius.circular(bottomSheet),
        topRight: Radius.circular(bottomSheet),
      );
}

// ---------------------------------------------------------------------------
// Shadow tokens — sky-tinted clay depth system
// ---------------------------------------------------------------------------

abstract final class AppShadow {
  /// Subtle ambient shadow for standard clay cards (light mode).
  static const List<BoxShadow> clayLight = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x140EA5E9),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Stronger colored glow for hero clay cards (light mode).
  static const List<BoxShadow> clayHeroLight = [
    BoxShadow(
      color: Color(0x590EA5E9),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Pressed state — only ambient shadow remains (light mode).
  static const List<BoxShadow> clayPressedLight = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Subtle ambient shadow for standard clay cards (dark mode).
  /// Neutral depth only — no sky-blue glow (avoids halo on dark surfaces).
  static const List<BoxShadow> clayDark = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Hero card shadow — dark mode (neutral, no colored glow).
  static const List<BoxShadow> clayHeroDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// Pressed state — dark mode.
  static const List<BoxShadow> clayPressedDark = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// FAB floating shadow.
  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x330EA5E9),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];
}
