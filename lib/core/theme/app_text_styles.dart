import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers using Alyamama from Google Fonts.
abstract final class AppTextStyles {
  static TextStyle get _headingBase => GoogleFonts.getFont(
        'Alyamama',
        fontWeight: FontWeight.w700,
      );

  static TextStyle headingLarge = _headingBase.copyWith(fontSize: 28);

  static TextStyle headingMedium = _headingBase.copyWith(fontSize: 22);

  static TextStyle headingSmall = GoogleFonts.getFont(
    'Alyamama',
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge = GoogleFonts.getFont(
    'Alyamama',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.getFont(
    'Alyamama',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.getFont(
    'Alyamama',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle label = GoogleFonts.getFont(
    'Alyamama',
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
