import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';

/// Builds light and dark themes for the application.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppThemeColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppThemeColors.dark);

  static ThemeData _build(Brightness brightness, AppThemeColors colors) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        secondary: AppColors.success,
        error: AppColors.expense,
      ),
      scaffoldBackgroundColor: colors.scaffoldBackground,
      dividerColor: colors.divider,
      textTheme: _textTheme(brightness, colors),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.scaffoldBackground,
        foregroundColor: colors.textPrimary,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.cardBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        labelStyle: AppTextStyles.inputLabel.copyWith(color: colors.textPrimary),
        floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.dashboardPrimary,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(color: colors.inputHint),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.primary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.inputTextStyleFor(colors),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        secondaryLabelStyle:
            AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        side: BorderSide(color: colors.cardBorder),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.dashboardPrimary,
        foregroundColor: colors.onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.dashboardPrimary,
          foregroundColor: colors.onPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.navBarBackground,
        indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return AppTextStyles.label.copyWith(
            color: colors.textSecondary,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryContainer);
          }
          return IconThemeData(color: colors.textSecondary);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? colors.textPrimary : colors.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: isLight ? colors.onPrimary : colors.textPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colors.textSecondary,
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness, AppThemeColors colors) {
    final base = ThemeData(brightness: brightness).textTheme;

    return base.copyWith(
      displayLarge:
          AppTextStyles.headingLarge.copyWith(color: colors.textPrimary),
      displayMedium:
          AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
      displaySmall:
          AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
      headlineMedium:
          AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
      titleLarge:
          AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: colors.textPrimary),
    );
  }
}
