import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Spacing tokens that scale with window size class.
abstract final class ResponsiveSpacing {
  static double pagePadding(WindowSizeClass sizeClass) {
    return switch (sizeClass) {
      WindowSizeClass.compact => 16,
      WindowSizeClass.medium => 24,
      _ => 32,
    };
  }

  static EdgeInsetsDirectional pageInsets(WindowSizeClass sizeClass) {
    final horizontal = pagePadding(sizeClass);
    return EdgeInsetsDirectional.symmetric(horizontal: horizontal);
  }

  static double sectionGap(WindowSizeClass sizeClass) {
    return switch (sizeClass) {
      WindowSizeClass.compact => 16,
      WindowSizeClass.medium => 20,
      _ => 24,
    };
  }
}
