import 'package:flutter/material.dart';

/// Application color palette — "سماء الثقة" (Sky of Trust) design system.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Sky-blue primary spectrum
  // ---------------------------------------------------------------------------

  /// Sky-500 — warm, inviting, trustworthy primary.
  static const Color primary = Color(0xFF0EA5E9);

  /// Sky-700 — deep pressed / active state.
  static const Color primaryDeep = Color(0xFF0369A1);

  /// Sky-100 — light surface tinting, accent backgrounds.
  static const Color primaryLight = Color(0xFFE0F2FE);

  /// Sky-400 — secondary accents, dark-mode primary.
  static const Color primaryAccent = Color(0xFF38BDF8);

  /// Legacy aliases kept for backwards compatibility.
  static const Color dashboardPrimary = Color(0xFF0EA5E9);
  static const Color dashboardPrimaryMuted = Color(0xFF38BDF8);
  static const Color primaryContainer = Color(0xFF0EA5E9);
  static const Color onPrimaryContainer = Color(0xFFE0F2FE);

  // ---------------------------------------------------------------------------
  // Semantic / financial colors
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  /// Debts and obligation indicators.
  static const Color debtAccent = Color(0xFFEA580C);

  // ---------------------------------------------------------------------------
  // Light-mode surface & background
  // ---------------------------------------------------------------------------

  /// Sky-50 — airy, breathing-room background.
  static const Color backgroundLight = Color(0xFFF0F9FF);

  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Slightly tinted white for elevated card surfaces.
  static const Color surfaceElevatedLight = Color(0xFFF8FBFF);

  static const Color textPrimaryLight = Color(0xFF0C1A2E);

  /// Secondary labels — sufficient contrast on white (~6:1).
  static const Color textSecondaryLight = Color(0xFF374151);

  static const Color textMutedLight = Color(0xFF6B7280);

  // ---------------------------------------------------------------------------
  // Dark-mode surface & background
  // ---------------------------------------------------------------------------

  /// Warm deep navy — replaces cold slate.
  static const Color backgroundDark = Color(0xFF0C1A2E);

  /// Warm dark surface.
  static const Color surfaceDark = Color(0xFF1A2D44);

  /// Elevated dark surface for cards.
  static const Color surfaceElevatedDark = Color(0xFF1F3352);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  /// Bumped to slate-300 for WCAG AA compliance (~5.2:1 on dark surface).
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  static const Color textMutedDark = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Glass / frost
  // ---------------------------------------------------------------------------

  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);

  // ---------------------------------------------------------------------------
  // Semantic tokens — light
  // ---------------------------------------------------------------------------

  static const Color borderLight = Color(0xFFE0F2FE);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color shadowLight = Color(0x0D000000);

  /// Sky-tinted ambient shadow on clay cards.
  static const Color shadowSkyLight = Color(0x140EA5E9);

  static const Color surfaceVariantLight = Color(0xFFF0F9FF);
  static const Color inputFillLight = Color(0xFFF0F9FF);
  static const Color inputTextLight = Color(0xFF0C1A2E);
  static const Color searchFieldLight = Color(0xFFE0F2FE);
  static const Color accentSurfaceLight = Color(0xFFE0F2FE);
  static const Color accentSurfaceBorderLight = Color(0xFF38BDF8);
  static const Color authGradientTopLight = Color(0xFFE0F2FE);
  static const Color authGradientBottomLight = Color(0xFFF0F9FF);

  // ---------------------------------------------------------------------------
  // Semantic tokens — dark
  // ---------------------------------------------------------------------------

  static const Color borderDark = Color(0xFF1F3A5A);
  static const Color dividerDark = Color(0xFF1F3A5A);
  static const Color shadowDark = Color(0x40000000);

  /// Ambient shadow on dark clay cards (neutral — no sky tint).
  static const Color shadowSkyDark = Color(0x26000000);

  static const Color surfaceVariantDark = Color(0xFF1A2D44);
  static const Color inputFillDark = Color(0xFF0C1A2E);
  static const Color inputTextDark = Color(0xFFF8FAFC);
  static const Color searchFieldDark = Color(0xFF0C1A2E);
  static const Color accentSurfaceDark = Color(0xFF1A3A5C);
  static const Color accentSurfaceBorderDark = Color(0xFF38BDF8);
  static const Color authGradientTopDark = Color(0xFF0C1A2E);
  static const Color authGradientBottomDark = Color(0xFF1A2D44);
}
