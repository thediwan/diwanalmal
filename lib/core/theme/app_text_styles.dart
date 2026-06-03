import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography helpers based on design system.
abstract final class AppTextStyles {
  static TextStyle get _headingBase => GoogleFonts.almarai(
        fontWeight: FontWeight.w700,
      );

  static TextStyle headingLarge = _headingBase.copyWith(fontSize: 28);

  static TextStyle headingMedium = _headingBase.copyWith(fontSize: 22);

  static TextStyle headingSmall = GoogleFonts.almarai(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle label = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
