import 'package:flutter/material.dart';

import '../app_theme_colors.dart';

// ---------------------------------------------------------------------------
// Palette identifier enum
// ---------------------------------------------------------------------------

/// Identifier for each available color palette.
///
/// Add a new value here when introducing a new palette, then register the
/// definition in [AppColorPaletteRegistry].
enum AppColorPaletteId {
  original,
  deepSea,
  gothicGlam,
  purpleHaze,
  turquoiseHarmony;

  /// Storage string — stable across renames (never change existing values).
  String get storageKey => switch (this) {
    AppColorPaletteId.original => 'original',
    AppColorPaletteId.deepSea => 'deep_sea',
    AppColorPaletteId.gothicGlam => 'gothic_glam',
    AppColorPaletteId.purpleHaze => 'purple_haze',
    AppColorPaletteId.turquoiseHarmony => 'turquoise_harmony',
  };

  static AppColorPaletteId fromStorageKey(String? key) =>
      AppColorPaletteId.values.firstWhere(
        (e) => e.storageKey == key,
        orElse: () => AppColorPaletteId.original,
      );
}

// ---------------------------------------------------------------------------
// Per-palette accent swatch
// ---------------------------------------------------------------------------

/// Brand / accent colors that live alongside [AppThemeColors].
///
/// These mirror the sky-blue fields of [AppColors] but are palette-specific
/// so widgets can access them via [context.palette] without importing
/// the concrete palette files.
@immutable
class AppAccentColors extends ThemeExtension<AppAccentColors> {
  const AppAccentColors({
    required this.primary,
    required this.primaryDeep,
    required this.primaryLight,
    required this.primaryAccent,
    required this.onPrimary,
  });

  final Color primary;

  /// Darker variant — pressed / active states.
  final Color primaryDeep;

  /// Very light tint — chip backgrounds, surface washes.
  final Color primaryLight;

  /// Brighter/lighter accent — dark-mode primary, secondary highlights.
  final Color primaryAccent;

  /// Text/icon color on top of [primary].
  final Color onPrimary;

  @override
  AppAccentColors copyWith({
    Color? primary,
    Color? primaryDeep,
    Color? primaryLight,
    Color? primaryAccent,
    Color? onPrimary,
  }) =>
      AppAccentColors(
        primary: primary ?? this.primary,
        primaryDeep: primaryDeep ?? this.primaryDeep,
        primaryLight: primaryLight ?? this.primaryLight,
        primaryAccent: primaryAccent ?? this.primaryAccent,
        onPrimary: onPrimary ?? this.onPrimary,
      );

  @override
  AppAccentColors lerp(ThemeExtension<AppAccentColors>? other, double t) {
    if (other is! AppAccentColors) return this;
    return AppAccentColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// Per-brightness palette scheme
// ---------------------------------------------------------------------------

/// All color tokens needed to build one brightness variant of a palette.
///
/// [accent] covers brand colors; [surfaces] covers backgrounds/text/inputs.
/// Financial semantic colors (success/expense/warning/debt) live in
/// [AppColors] and are intentionally NOT part of this struct.
@immutable
class AppPaletteScheme {
  const AppPaletteScheme({
    required this.accent,
    required this.surfaces,
  });

  final AppAccentColors accent;
  final AppThemeColors surfaces;
}

// ---------------------------------------------------------------------------
// Full palette definition
// ---------------------------------------------------------------------------

/// A complete theme palette — both brightness variants plus preview stops.
///
/// ### How to add a new palette
/// 1. Create `lib/core/theme/palettes/<name>_palette.dart`
/// 2. Declare a `const kMyPalette = AppColorPaletteDefinition(…)` in it
/// 3. Register it in [AppColorPaletteRegistry.all]
/// 4. Add l10n keys `palette<Name>` in `app_ar.arb` / `app_en.arb`
@immutable
class AppColorPaletteDefinition {
  const AppColorPaletteDefinition({
    required this.id,
    required this.nameKey,
    required this.previewStops,
    required this.light,
    required this.dark,
  });

  final AppColorPaletteId id;

  /// ARB localization key for the human-readable palette name.
  final String nameKey;

  /// 5 representative colors shown as a gradient strip in the UI.
  final List<Color> previewStops;

  final AppPaletteScheme light;
  final AppPaletteScheme dark;

  AppPaletteScheme schemeFor(Brightness brightness) =>
      brightness == Brightness.light ? light : dark;
}
