/// Material 3 window size classes based on available layout width.
enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large,
  extraLarge,
}

/// Breakpoint width thresholds (logical pixels).
abstract final class AppBreakpoints {
  static const double compactUpper = 600;
  static const double mediumUpper = 840;
  static const double expandedUpper = 1200;
  static const double largeUpper = 1600;

  static const double contentMaxMedium = 720;
  static const double contentMaxExpanded = 960;
  static const double contentMaxLarge = 1200;

  static const double formMaxWidth = 560;
  static const double masterPaneWidth = 360;
}

WindowSizeClass windowSizeClassFor(double width) {
  if (width < AppBreakpoints.compactUpper) return WindowSizeClass.compact;
  if (width < AppBreakpoints.mediumUpper) return WindowSizeClass.medium;
  if (width < AppBreakpoints.expandedUpper) return WindowSizeClass.expanded;
  if (width < AppBreakpoints.largeUpper) return WindowSizeClass.large;
  return WindowSizeClass.extraLarge;
}

bool isExpandedOrWider(WindowSizeClass sizeClass) {
  return sizeClass == WindowSizeClass.expanded ||
      sizeClass == WindowSizeClass.large ||
      sizeClass == WindowSizeClass.extraLarge;
}

double contentMaxWidthFor(WindowSizeClass sizeClass) {
  return switch (sizeClass) {
    WindowSizeClass.compact => double.infinity,
    WindowSizeClass.medium => AppBreakpoints.contentMaxMedium,
    WindowSizeClass.expanded => AppBreakpoints.contentMaxExpanded,
    WindowSizeClass.large || WindowSizeClass.extraLarge =>
      AppBreakpoints.contentMaxLarge,
  };
}

int gridColumnCountFor(WindowSizeClass sizeClass) {
  return switch (sizeClass) {
    WindowSizeClass.compact => 1,
    WindowSizeClass.medium => 2,
    WindowSizeClass.expanded => 3,
    WindowSizeClass.large || WindowSizeClass.extraLarge => 4,
  };
}
