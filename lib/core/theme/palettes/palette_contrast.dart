import 'package:flutter/material.dart';

/// WCAG-relative luminance and contrast utilities.
///
/// Used at palette definition time (compile-time const not possible for
/// floating-point math, but called once during [AppTheme.build]).
abstract final class PaletteContrast {
  /// Returns white or black, whichever has ≥ 4.5:1 contrast with [background].
  static Color onColor(Color background) {
    final l = _relativeLuminance(background);
    final onWhite = (1.0 + 0.05) / (l + 0.05);
    final onBlack = (l + 0.05) / (0.0 + 0.05);
    return onWhite >= onBlack ? Colors.white : Colors.black;
  }

  /// Relative luminance per WCAG 2.1 §1.4.3.
  static double _relativeLuminance(Color color) {
    double linearize(double c) {
      c /= 255;
      return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055);
    }

    final r = linearize(color.r * 255);
    final g = linearize(color.g * 255);
    final b = linearize(color.b * 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Derives a surface-tinted input fill from [surface] with [alpha] overlay.
  static Color inputFill(Color surface, {double alpha = 0.06}) =>
      Color.alphaBlend(Colors.white.withValues(alpha: alpha), surface);

  /// Derives a divider from [surface]: slightly lighter in dark, darker in light.
  static Color divider(Color surface, {bool isDark = true}) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.black.withValues(alpha: 0.08);

  /// Slightly lightened surface for cards/panels.
  static Color surfaceElevated(Color surface, {bool isDark = true}) =>
      isDark
          ? Color.alphaBlend(Colors.white.withValues(alpha: 0.06), surface)
          : Color.alphaBlend(Colors.black.withValues(alpha: 0.03), surface);
}
