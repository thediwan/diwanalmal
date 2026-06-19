import 'package:flutter/material.dart';

/// Central typography tokens — single place to adjust fonts app-wide.
///
/// Wire [textScaleFactor] and font family overrides from settings later.
abstract final class AppTypography {
  /// Multiplier applied to all font sizes (settings hook).
  static double textScaleFactor = 1.0;

  /// Heading font (titles, app bar, section headers).
  static const String headingFontFamily = 'Qomra';

  /// Body font (paragraphs, labels, inputs, buttons).
  static const String bodyFontFamily = 'Alyamama';

  // --- Size tokens (before scale) ---

  /// Hero balance display — largest text in the app.
  static const double sizeBalanceDisplay = 40;

  static const double sizeHeadingLarge = 30;
  static const double sizeHeadingMedium = 24;
  static const double sizeHeadingSmall = 18;
  static const double sizeBodyLarge = 16;
  static const double sizeBodyMedium = 14;
  static const double sizeBodySmall = 12;
  static const double sizeLabel = 13;

  /// Currency codes, status chips — small caps feel.
  static const double sizeLabelSmall = 11;

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
    return _font(
      family: headingFontFamily,
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
    return _font(
      family: bodyFontFamily,
      fontSize: scaled(size),
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _font({
    required String family,
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
