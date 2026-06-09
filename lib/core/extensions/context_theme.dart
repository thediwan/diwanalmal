import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

/// Theme helpers for semantic app colors.
extension ContextTheme on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}
