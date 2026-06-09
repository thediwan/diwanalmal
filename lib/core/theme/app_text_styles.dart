import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import 'app_theme_colors.dart';

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

  /// Small captions on light/dark surfaces.
  static TextStyle captionOnSurface(AppThemeColors colors) => bodySmall.copyWith(
        color: colors.textMuted,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );

  /// Section labels on surfaces.
  static TextStyle labelOnSurface(AppThemeColors colors) => label.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      );

  /// Typed text inside form fields — dark for readability.
  static TextStyle inputTextStyleFor(AppThemeColors colors) => bodyLarge.copyWith(
        color: colors.inputText,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      );

  /// Placeholder / hint text inside form fields.
  static TextStyle inputHint = bodyMedium.copyWith(
    color: AppColors.textSecondaryLight,
    fontWeight: FontWeight.w400,
  );

  /// Floating labels on form fields.
  static TextStyle inputLabel = label.copyWith(
    color: AppColors.textPrimaryLight,
    fontWeight: FontWeight.w600,
  );

  /// @deprecated Use [captionOnSurface] with theme colors.
  static TextStyle captionOnLight = bodySmall.copyWith(
    color: AppColors.textSecondaryLight,
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  /// @deprecated Use [labelOnSurface] with theme colors.
  static TextStyle labelOnLight = label.copyWith(
    color: AppColors.textSecondaryLight,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  /// @deprecated Use [inputTextStyleFor].
  static TextStyle inputText = bodyLarge.copyWith(
    color: AppColors.inputTextLight,
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );
}
