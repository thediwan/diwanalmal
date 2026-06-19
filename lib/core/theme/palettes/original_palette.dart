import 'package:flutter/material.dart';

import '../app_theme_colors.dart';
import 'app_color_palette.dart';

/// Original palette — sky-blue light mode, neutral dark-grey dark mode.
///
/// Dark surfaces are intentionally grey (not navy-blue) to avoid the
/// "blue glow everywhere" problem that plagued the earlier design.
const kOriginalPalette = AppColorPaletteDefinition(
  id: AppColorPaletteId.original,
  nameKey: 'paletteOriginal',
  previewStops: [
    Color(0xFF0EA5E9), // primary
    Color(0xFF38BDF8), // accent
    Color(0xFF0369A1), // deep
    Color(0xFF1E1E1E), // dark surface
    Color(0xFFF0F9FF), // light bg
  ],
  light: AppPaletteScheme(
    accent: AppAccentColors(
      primary: Color(0xFF0EA5E9),
      primaryDeep: Color(0xFF0369A1),
      primaryLight: Color(0xFFE0F2FE),
      primaryAccent: Color(0xFF38BDF8),
      onPrimary: Colors.white,
    ),
    surfaces: AppThemeColors(
      scaffoldBackground: Color(0xFFF0F9FF),
      surface: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFF8FBFF),
      surfaceVariant: Color(0xFFF0F9FF),
      cardBorder: Color(0xFFE0F2FE),
      cardShadow: Color(0x0D000000),
      cardShadowSky: Color(0x140EA5E9),
      divider: Color(0xFFE5E7EB),
      textPrimary: Color(0xFF0C1A2E),
      textSecondary: Color(0xFF374151),
      textMuted: Color(0xFF6B7280),
      inputText: Color(0xFF0C1A2E),
      inputHint: Color(0xFF6B7280),
      inputBorder: Color(0xFFE0F2FE),
      inputFill: Color(0xFFF0F9FF),
      authGradientTop: Color(0xFFE0F2FE),
      authGradientBottom: Color(0xFFF0F9FF),
      navBarBackground: Color(0xFFFFFFFF),
      searchFieldFill: Color(0xFFE0F2FE),
      accentSurface: Color(0xFFE0F2FE),
      accentSurfaceBorder: Color(0xFF38BDF8),
      dropdownBackground: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
    ),
  ),
  dark: AppPaletteScheme(
    accent: AppAccentColors(
      primary: Color(0xFF38BDF8),
      primaryDeep: Color(0xFF0EA5E9),
      primaryLight: Color(0xFF1A3A5A),
      primaryAccent: Color(0xFF7DD3FC),
      onPrimary: Colors.black,
    ),
    surfaces: AppThemeColors(
      scaffoldBackground: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      surfaceElevated: Color(0xFF2C2C2C),
      surfaceVariant: Color(0xFF242424),
      cardBorder: Color(0xFF3A3A3A),
      cardShadow: Color(0x40000000),
      cardShadowSky: Color(0x26000000),
      divider: Color(0xFF333333),
      textPrimary: Color(0xFFF1F5F9),
      textSecondary: Color(0xFFCBD5E1),
      textMuted: Color(0xFF94A3B8),
      inputText: Color(0xFFF8FAFC),
      inputHint: Color(0xFF94A3B8),
      inputBorder: Color(0xFF3A3A3A),
      inputFill: Color(0xFF1A1A1A),
      authGradientTop: Color(0xFF121212),
      authGradientBottom: Color(0xFF1E1E1E),
      navBarBackground: Color(0xFF1A1A1A),
      searchFieldFill: Color(0xFF1A1A1A),
      accentSurface: Color(0xFF1A2A3A),
      accentSurfaceBorder: Color(0xFF38BDF8),
      dropdownBackground: Color(0xFF1E1E1E),
      onPrimary: Colors.black,
    ),
  ),
);
