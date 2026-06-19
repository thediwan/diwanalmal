import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'app_motion.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';
import 'palettes/app_color_palette.dart';
import 'palettes/app_color_palette_registry.dart';

/// Builds light and dark [ThemeData] for the given palette.
///
/// Usage (in main.dart):
/// ```dart
/// theme:     AppTheme.build(palette: paletteId, brightness: Brightness.light),
/// darkTheme: AppTheme.build(palette: paletteId, brightness: Brightness.dark),
/// ```
abstract final class AppTheme {
  /// Static convenience wrappers kept for backwards-compatible call sites
  /// that were not yet migrated (removed once all callers use [build]).
  static ThemeData light() => build(
        palette: AppColorPaletteId.original,
        brightness: Brightness.light,
      );

  static ThemeData dark() => build(
        palette: AppColorPaletteId.original,
        brightness: Brightness.dark,
      );

  static ThemeData build({
    required AppColorPaletteId palette,
    required Brightness brightness,
  }) {
    final definition = AppColorPaletteRegistry.find(palette);
    final scheme = definition.schemeFor(brightness);
    final accent = scheme.accent;
    final colors = scheme.surfaces;
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors, accent],
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent.primary,
        brightness: brightness,
        primary: accent.primary,
        onPrimary: accent.onPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        secondary: AppColors.success,
        error: AppColors.expense,
        tertiary: accent.primaryAccent,
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
        color: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorderRadius,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        labelStyle: AppTextStyles.inputLabel.copyWith(color: colors.textPrimary),
        floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
          color: accent.primary,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(color: colors.inputHint),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBorderRadius,
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorderRadius,
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorderRadius,
          borderSide: BorderSide(color: accent.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent.primary,
        selectionColor: accent.primary.withValues(alpha: 0.25),
        selectionHandleColor: accent.primary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.inputTextStyleFor(colors),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent.primary,
        foregroundColor: accent.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent.primary,
          foregroundColor: accent.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent.primary,
          side: BorderSide(color: accent.primary),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent.primary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorderRadius,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: accent.primary.withValues(alpha: 0.15),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        secondaryLabelStyle:
            AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        side: BorderSide(color: colors.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.navBarBackground,
        indicatorColor: accent.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label.copyWith(
              color: accent.primary,
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
            return IconThemeData(color: accent.primary);
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _DirectionalPageTransitionBuilder(),
          TargetPlatform.iOS: _DirectionalPageTransitionBuilder(),
          TargetPlatform.windows: _DirectionalPageTransitionBuilder(),
          TargetPlatform.macOS: _DirectionalPageTransitionBuilder(),
          TargetPlatform.linux: _DirectionalPageTransitionBuilder(),
        },
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

/// RTL-aware slide + fade page transition.
class _DirectionalPageTransitionBuilder extends PageTransitionsBuilder {
  const _DirectionalPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final isRtl = Directionality.maybeOf(context) == TextDirection.rtl;

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      return FadeTransition(opacity: animation, child: child);
    }

    final enterBegin =
        isRtl ? const Offset(-0.06, 0) : const Offset(0.06, 0);
    final exitEnd =
        isRtl ? const Offset(0.03, 0) : const Offset(-0.03, 0);

    final enterTween = Tween(begin: enterBegin, end: Offset.zero)
        .chain(CurveTween(curve: AppMotion.easePage));
    final exitTween = Tween(begin: Offset.zero, end: exitEnd)
        .chain(CurveTween(curve: AppMotion.easePage));
    final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: AppMotion.easeEnter));

    return SlideTransition(
      position: exitTween.animate(secondaryAnimation),
      child: FadeTransition(
        opacity: fadeTween.animate(animation),
        child: SlideTransition(
          position: enterTween.animate(animation),
          child: child,
        ),
      ),
    );
  }
}
