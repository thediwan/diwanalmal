import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../extensions/context_theme.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';

/// Shared decoration and text styles for form fields.
abstract final class AppFormFields {
  /// Dark, high-contrast typed text for form fields (theme-aware).
  static TextStyle inputTextStyleOf(BuildContext context) {
    return inputTextStyleFor(context.appColors);
  }

  static TextStyle inputTextStyleFor(AppThemeColors colors) {
    return AppTextStyles.inputTextStyleFor(colors);
  }

  static InputDecoration decoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    EdgeInsetsGeometry? contentPadding,
    Color? fillColor,
  }) {
    final colors = context.appColors;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      labelStyle: AppTextStyles.inputLabel.copyWith(color: colors.textPrimary),
      floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.dashboardPrimary,
      ),
      hintStyle: AppTextStyles.inputHint.copyWith(color: colors.inputHint),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.dashboardPrimary,
          width: 1.5,
        ),
      ),
      filled: true,
      fillColor: fillColor ?? colors.inputFill,
    );
  }
}
