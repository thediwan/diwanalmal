import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';
import '../theme/palettes/app_color_palette.dart';
import '../theme/palettes/original_palette.dart';

/// Theme helpers for semantic app colors.
extension ContextTheme on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;

  /// Palette accent colors (primary, primaryDeep, etc.) for the active palette.
  AppAccentColors get palette =>
      Theme.of(this).extension<AppAccentColors>() ??
      kOriginalPalette.light.accent;
}
