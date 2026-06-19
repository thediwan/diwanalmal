import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme_colors.dart';
import 'app_typography.dart';

/// Semantic text styles — all sizes and families come from [AppTypography].
abstract final class AppTextStyles {
  /// Hero balance display — 40px Qomra bold.
  static TextStyle get balanceDisplay => AppTypography.heading(
        size: AppTypography.sizeBalanceDisplay,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headingLarge => AppTypography.heading(
        size: AppTypography.sizeHeadingLarge,
      );

  static TextStyle get headingMedium => AppTypography.heading(
        size: AppTypography.sizeHeadingMedium,
      );

  static TextStyle get headingSmall => AppTypography.heading(
        size: AppTypography.sizeHeadingSmall,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => AppTypography.body(
        size: AppTypography.sizeBodyLarge,
      );

  static TextStyle get bodyMedium => AppTypography.body(
        size: AppTypography.sizeBodyMedium,
      );

  static TextStyle get bodySmall => AppTypography.body(
        size: AppTypography.sizeBodySmall,
      );

  static TextStyle get label => AppTypography.body(
        size: AppTypography.sizeLabel,
        fontWeight: FontWeight.w500,
      );

  /// Currency codes, status chips, small caps.
  static TextStyle get labelSmall => AppTypography.body(
        size: AppTypography.sizeLabelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      );

  /// Small captions on light/dark surfaces.
  static TextStyle captionOnSurface(AppThemeColors colors) => bodySmall.copyWith(
        color: colors.textMuted,
        fontWeight: FontWeight.w500,
        fontSize: AppTypography.scaled(AppTypography.sizeBodySmall),
      );

  /// Section labels on surfaces (form field group titles).
  static TextStyle labelOnSurface(AppThemeColors colors) => label.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: AppTypography.scaled(AppTypography.sizeLabel),
      );

  /// Typed text inside form fields and dropdowns.
  static TextStyle inputTextStyleFor(AppThemeColors colors) => bodyLarge.copyWith(
        color: colors.inputText,
        fontWeight: FontWeight.w600,
        fontSize: AppTypography.scaled(AppTypography.sizeInput),
      );

  /// Dropdown menu item text.
  static TextStyle dropdownItemFor(AppThemeColors colors) => bodyMedium.copyWith(
        color: colors.textPrimary,
        fontSize: AppTypography.scaled(AppTypography.sizeBodyMedium),
      );

  /// Placeholder / hint text inside form fields.
  static TextStyle get inputHint => bodyMedium.copyWith(
        color: AppColors.textSecondaryLight,
        fontWeight: FontWeight.w400,
      );

  /// Floating labels on form fields.
  static TextStyle get inputLabel => label.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
      );

  /// @deprecated Use [captionOnSurface] with theme colors.
  static TextStyle get captionOnLight => bodySmall.copyWith(
        color: AppColors.textSecondaryLight,
        fontWeight: FontWeight.w500,
        fontSize: AppTypography.scaled(AppTypography.sizeBodySmall),
      );

  /// @deprecated Use [labelOnSurface] with theme colors.
  static TextStyle get labelOnLight => label.copyWith(
        color: AppColors.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: AppTypography.scaled(AppTypography.sizeLabel),
      );

  /// @deprecated Use [inputTextStyleFor].
  static TextStyle get inputText => bodyLarge.copyWith(
        color: AppColors.inputTextLight,
        fontWeight: FontWeight.w600,
        fontSize: AppTypography.scaled(AppTypography.sizeInput),
      );
}
