import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic colors resolved per brightness — use via [Theme.of(context).extension].
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.scaffoldBackground,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceVariant,
    required this.cardBorder,
    required this.cardShadow,
    required this.cardShadowSky,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.inputText,
    required this.inputHint,
    required this.inputBorder,
    required this.inputFill,
    required this.authGradientTop,
    required this.authGradientBottom,
    required this.navBarBackground,
    required this.searchFieldFill,
    required this.accentSurface,
    required this.accentSurfaceBorder,
    required this.dropdownBackground,
    required this.onPrimary,
  });

  final Color scaffoldBackground;
  final Color surface;

  /// Slightly tinted elevated surface for clay cards.
  final Color surfaceElevated;
  final Color surfaceVariant;
  final Color cardBorder;
  final Color cardShadow;

  /// Sky-tinted ambient shadow color for clay cards.
  final Color cardShadowSky;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color inputText;
  final Color inputHint;
  final Color inputBorder;
  final Color inputFill;
  final Color authGradientTop;
  final Color authGradientBottom;
  final Color navBarBackground;
  final Color searchFieldFill;
  final Color accentSurface;
  final Color accentSurfaceBorder;
  final Color dropdownBackground;
  final Color onPrimary;

  static const AppThemeColors light = AppThemeColors(
    scaffoldBackground: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceElevated: AppColors.surfaceElevatedLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    cardBorder: AppColors.borderLight,
    cardShadow: AppColors.shadowLight,
    cardShadowSky: AppColors.shadowSkyLight,
    divider: AppColors.dividerLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textMuted: AppColors.textMutedLight,
    inputText: AppColors.inputTextLight,
    inputHint: AppColors.textMutedLight,
    inputBorder: AppColors.borderLight,
    inputFill: AppColors.inputFillLight,
    authGradientTop: AppColors.authGradientTopLight,
    authGradientBottom: AppColors.authGradientBottomLight,
    navBarBackground: AppColors.surfaceLight,
    searchFieldFill: AppColors.searchFieldLight,
    accentSurface: AppColors.accentSurfaceLight,
    accentSurfaceBorder: AppColors.accentSurfaceBorderLight,
    dropdownBackground: AppColors.surfaceLight,
    onPrimary: Colors.white,
  );

  static const AppThemeColors dark = AppThemeColors(
    scaffoldBackground: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceElevated: AppColors.surfaceElevatedDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    cardBorder: AppColors.borderDark,
    cardShadow: AppColors.shadowDark,
    cardShadowSky: AppColors.shadowSkyDark,
    divider: AppColors.dividerDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textMuted: AppColors.textMutedDark,
    inputText: AppColors.inputTextDark,
    inputHint: AppColors.textMutedDark,
    inputBorder: AppColors.borderDark,
    inputFill: AppColors.inputFillDark,
    authGradientTop: AppColors.authGradientTopDark,
    authGradientBottom: AppColors.authGradientBottomDark,
    navBarBackground: AppColors.surfaceDark,
    searchFieldFill: AppColors.searchFieldDark,
    accentSurface: AppColors.accentSurfaceDark,
    accentSurfaceBorder: AppColors.accentSurfaceBorderDark,
    dropdownBackground: AppColors.surfaceDark,
    onPrimary: Colors.white,
  );

  @override
  AppThemeColors copyWith({
    Color? scaffoldBackground,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceVariant,
    Color? cardBorder,
    Color? cardShadow,
    Color? cardShadowSky,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? inputText,
    Color? inputHint,
    Color? inputBorder,
    Color? inputFill,
    Color? authGradientTop,
    Color? authGradientBottom,
    Color? navBarBackground,
    Color? searchFieldFill,
    Color? accentSurface,
    Color? accentSurfaceBorder,
    Color? dropdownBackground,
    Color? onPrimary,
  }) {
    return AppThemeColors(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      cardShadowSky: cardShadowSky ?? this.cardShadowSky,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      inputText: inputText ?? this.inputText,
      inputHint: inputHint ?? this.inputHint,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFill: inputFill ?? this.inputFill,
      authGradientTop: authGradientTop ?? this.authGradientTop,
      authGradientBottom: authGradientBottom ?? this.authGradientBottom,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      searchFieldFill: searchFieldFill ?? this.searchFieldFill,
      accentSurface: accentSurface ?? this.accentSurface,
      accentSurfaceBorder: accentSurfaceBorder ?? this.accentSurfaceBorder,
      dropdownBackground: dropdownBackground ?? this.dropdownBackground,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      cardShadowSky: Color.lerp(cardShadowSky, other.cardShadowSky, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      inputText: Color.lerp(inputText, other.inputText, t)!,
      inputHint: Color.lerp(inputHint, other.inputHint, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      authGradientTop: Color.lerp(authGradientTop, other.authGradientTop, t)!,
      authGradientBottom:
          Color.lerp(authGradientBottom, other.authGradientBottom, t)!,
      navBarBackground:
          Color.lerp(navBarBackground, other.navBarBackground, t)!,
      searchFieldFill: Color.lerp(searchFieldFill, other.searchFieldFill, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      accentSurfaceBorder:
          Color.lerp(accentSurfaceBorder, other.accentSurfaceBorder, t)!,
      dropdownBackground:
          Color.lerp(dropdownBackground, other.dropdownBackground, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}
