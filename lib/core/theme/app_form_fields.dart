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

  /// Section label above a field group (category, type, etc.).
  static TextStyle sectionLabelStyleOf(BuildContext context) {
    return AppTextStyles.labelOnSurface(context.appColors);
  }

  static TextStyle sectionLabelStyleFor(AppThemeColors colors) {
    return AppTextStyles.labelOnSurface(colors);
  }

  /// Text style for dropdown menu items.
  static TextStyle dropdownItemStyleOf(BuildContext context) {
    return AppTextStyles.dropdownItemFor(context.appColors);
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

  /// Borderless variant used inside bottom sheets (matches date picker rows).
  static InputDecoration dropdownDecoration(
    BuildContext context, {
    Color? fillColor,
  }) {
    final colors = context.appColors;
    return decoration(
      context,
      fillColor: fillColor ?? colors.inputFill,
    ).copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.dashboardPrimary,
          width: 1.5,
        ),
      ),
    );
  }

  /// Themed [DropdownButtonFormField] with unified typography.
  static Widget dropdown<T>({
    required BuildContext context,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    Color? fillColor,
  }) {
    final colors = context.appColors;

    return DropdownButtonFormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: inputTextStyleOf(context),
      dropdownColor: colors.surface,
      iconEnabledColor: colors.textSecondary,
      decoration: dropdownDecoration(context, fillColor: fillColor),
    );
  }

  /// Builds a [DropdownMenuItem] with app typography.
  static DropdownMenuItem<T> dropdownItem<T>({
    required BuildContext context,
    required T value,
    required String label,
  }) {
    return DropdownMenuItem<T>(
      value: value,
      child: Text(
        label,
        style: dropdownItemStyleOf(context),
      ),
    );
  }
}
