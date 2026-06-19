import 'app_color_palette.dart';
import 'deep_sea_palette.dart';
import 'gothic_glam_palette.dart';
import 'original_palette.dart';
import 'purple_haze_palette.dart';
import 'turquoise_harmony_palette.dart';

/// Central registry of all available color palettes.
///
/// To add a new palette:
/// 1. Create a file in this directory defining `const kMyPalette`
/// 2. Import it below
/// 3. Add it to [all]
abstract final class AppColorPaletteRegistry {
  static const List<AppColorPaletteDefinition> all = [
    kOriginalPalette,
    kDeepSeaPalette,
    kGothicGlamPalette,
    kPurpleHazePalette,
    kTurquoiseHarmonyPalette,
  ];

  static AppColorPaletteDefinition find(AppColorPaletteId id) =>
      all.firstWhere(
        (p) => p.id == id,
        orElse: () => kOriginalPalette,
      );
}
