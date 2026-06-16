import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography tokens — single place to adjust fonts app-wide.
///
/// Wire [textScaleFactor] and font family overrides from settings later.
abstract final class AppTypography {
  /// Multiplier applied to all font sizes (settings hook).
  static double textScaleFactor = 1.0;

  /// Heading font (titles, app bar, section headers).
  static const String headingFontFamily = 'Almarai';

  /// Body font (paragraphs, labels, inputs, buttons).
  static const String bodyFontFamily = 'Cairo';

  // --- Size tokens (before scale) ---

  static const double sizeHeadingLarge = 28;
  static const double sizeHeadingMedium = 22;
  static const double sizeHeadingSmall = 18;
  static const double sizeBodyLarge = 16;
  static const double sizeBodyMedium = 14;
  static const double sizeBodySmall = 12;
  static const double sizeLabel = 13;
  static const double sizeInput = 15;

  /// Scales a raw font size by [textScaleFactor].
  static double scaled(double size) => size * textScaleFactor;

  /// Builds a heading [TextStyle] using [headingFontFamily].
  static TextStyle heading({
    required double size,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return _headingFont(
      fontSize: scaled(size),
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Builds a body [TextStyle] using [bodyFontFamily].
  static TextStyle body({
    required double size,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return _bodyFont(
      fontSize: scaled(size),
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Styles to preload at startup so first paint does not block on fonts.
  static List<TextStyle> get preloadStyles => [
        heading(size: sizeHeadingLarge, fontWeight: FontWeight.w700),
        body(size: sizeBodyLarge),
        body(size: sizeBodyMedium),
        body(size: sizeInput, fontWeight: FontWeight.w600),
      ];

  static TextStyle _headingFont({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.almarai(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _bodyFont({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
