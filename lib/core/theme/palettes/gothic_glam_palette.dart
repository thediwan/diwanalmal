import 'package:flutter/material.dart';

import '../app_theme_colors.dart';
import 'app_color_palette.dart';

/// Gothic Glam palette — `000000 · 3d2645 · 832161 · da4167 · f0eff4`
///
/// Dark scaffold is lifted to `#0A0A0A` (not pure black) to avoid
/// OLED crushing and improve card contrast.
const kGothicGlamPalette = AppColorPaletteDefinition(
  id: AppColorPaletteId.gothicGlam,
  nameKey: 'paletteGothicGlam',
  previewStops: [
    Color(0xFF000000),
    Color(0xFF3d2645),
    Color(0xFF832161),
    Color(0xFFda4167),
    Color(0xFFf0eff4),
  ],
  light: AppPaletteScheme(
    accent: AppAccentColors(
      primary: Color(0xFF832161),
      primaryDeep: Color(0xFF5A1040),
      primaryLight: Color(0xFFF7E2ED),
      primaryAccent: Color(0xFFda4167),
      onPrimary: Colors.white,
    ),
    surfaces: AppThemeColors(
      scaffoldBackground: Color(0xFFf0eff4),
      surface: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFF7F6F9),
      surfaceVariant: Color(0xFFEEEDF2),
      cardBorder: Color(0xFFE0DDE8),
      cardShadow: Color(0x0D000000),
      cardShadowSky: Color(0x14832161),
      divider: Color(0xFFDDDAE5),
      textPrimary: Color(0xFF1A0A20),
      textSecondary: Color(0xFF3D2645),
      textMuted: Color(0xFF70607A),
      inputText: Color(0xFF1A0A20),
      inputHint: Color(0xFF70607A),
      inputBorder: Color(0xFFD0CCE0),
      inputFill: Color(0xFFEEEDF2),
      authGradientTop: Color(0xFFF7E2ED),
      authGradientBottom: Color(0xFFf0eff4),
      navBarBackground: Color(0xFFFFFFFF),
      searchFieldFill: Color(0xFFEDE8F5),
      accentSurface: Color(0xFFF7E2ED),
      accentSurfaceBorder: Color(0xFFda4167),
      dropdownBackground: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
    ),
  ),
  dark: AppPaletteScheme(
    accent: AppAccentColors(
      primary: Color(0xFFda4167),
      primaryDeep: Color(0xFF832161),
      primaryLight: Color(0xFF4A1A3A),
      primaryAccent: Color(0xFFE87090),
      onPrimary: Colors.white,
    ),
    surfaces: AppThemeColors(
      scaffoldBackground: Color(0xFF0A0A0A),
      surface: Color(0xFF3d2645),
      surfaceElevated: Color(0xFF4E3358),
      surfaceVariant: Color(0xFF3A2242),
      cardBorder: Color(0xFF5E3A70),
      cardShadow: Color(0x40000000),
      cardShadowSky: Color(0x26000000),
      divider: Color(0xFF4A2E56),
      textPrimary: Color(0xFFf0eff4),
      textSecondary: Color(0xFFCCC8D5),
      textMuted: Color(0xFF9E8FAE),
      inputText: Color(0xFFf0eff4),
      inputHint: Color(0xFF9E8FAE),
      inputBorder: Color(0xFF5E3A70),
      inputFill: Color(0xFF2A1530),
      authGradientTop: Color(0xFF0A0A0A),
      authGradientBottom: Color(0xFF3d2645),
      navBarBackground: Color(0xFF1A0E20),
      searchFieldFill: Color(0xFF2A1530),
      accentSurface: Color(0xFF4A1A3A),
      accentSurfaceBorder: Color(0xFFda4167),
      dropdownBackground: Color(0xFF3d2645),
      onPrimary: Colors.white,
    ),
  ),
);
