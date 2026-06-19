import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/palettes/app_color_palette.dart';
import '../../core/theme/palettes/app_color_palette_registry.dart';
import '../../core/widgets/clay_card.dart';
import '../../models/amount_format_style.dart';
import '../../providers/settings_provider.dart';

/// Theme, palette, amount format, and advanced appearance options.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileAppearanceCustomize)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- 3-way clay theme toggle ---
          _SectionLabel(label: l10n.settingsAppearance),
          const SizedBox(height: 12),
          _ClayThemeToggle(
            current: settings.themeMode,
            onChanged: settings.setThemeMode,
            lightLabel: l10n.settingsThemeLight,
            darkLabel: l10n.settingsThemeDark,
            systemLabel: l10n.settingsThemeSystem,
          ),
          const SizedBox(height: 28),
          // --- Color palette ---
          _SectionLabel(label: l10n.settingsColorPalette),
          const SizedBox(height: 12),
          _PalettePickerSection(
            currentId: settings.colorPaletteId,
            onChanged: settings.setColorPalette,
          ),
          const SizedBox(height: 28),
          // --- Amount format ---
          _SectionLabel(label: l10n.settingsAmountFormat),
          const SizedBox(height: 4),
          Text(
            l10n.settingsAmountFormatSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClayCard(
            elevation: ClayElevation.standard,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _FormatOption(
                  label: l10n.settingsAmountFormatWestern,
                  value: AmountFormatStyle.western,
                  groupValue: settings.amountFormatStyle,
                  onChanged: settings.setAmountFormatStyle,
                ),
                Divider(height: 1, color: colors.divider, indent: 56),
                _FormatOption(
                  label: l10n.settingsAmountFormatEuropean,
                  value: AmountFormatStyle.european,
                  groupValue: settings.amountFormatStyle,
                  onChanged: settings.setAmountFormatStyle,
                ),
                Divider(height: 1, color: colors.divider, indent: 56),
                _FormatOption(
                  label: l10n.settingsAmountFormatPlain,
                  value: AmountFormatStyle.plain,
                  groupValue: settings.amountFormatStyle,
                  onChanged: settings.setAmountFormatStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette picker section
// ---------------------------------------------------------------------------

class _PalettePickerSection extends StatelessWidget {
  const _PalettePickerSection({
    required this.currentId,
    required this.onChanged,
  });

  final AppColorPaletteId currentId;
  final ValueChanged<AppColorPaletteId> onChanged;

  String _nameFor(BuildContext context, String key) {
    final l10n = context.l10n;
    return switch (key) {
      'paletteOriginal' => l10n.paletteOriginal,
      'paletteDeepSea' => l10n.paletteDeepSea,
      'paletteGothicGlam' => l10n.paletteGothicGlam,
      'palettePurpleHaze' => l10n.palettePurpleHaze,
      'paletteTurquoiseHarmony' => l10n.paletteTurquoiseHarmony,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppColorPaletteRegistry.all
          .map((palette) => _PaletteCard(
                palette: palette,
                isSelected: palette.id == currentId,
                name: _nameFor(context, palette.nameKey),
                onTap: () => onChanged(palette.id),
              ))
          .toList(),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.name,
    required this.onTap,
  });

  final AppColorPaletteDefinition palette;
  final bool isSelected;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClayCard(
        elevation: isSelected ? ClayElevation.standard : ClayElevation.low,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            // 5-stop gradient strip
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 28,
                child: Row(
                  children: palette.previewStops
                      .map(
                        (c) => Expanded(
                          child: ColoredBox(color: c),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme mode toggle
// ---------------------------------------------------------------------------

/// Three-way clay chip toggle for light / dark / system theme.
class _ClayThemeToggle extends StatelessWidget {
  const _ClayThemeToggle({
    required this.current,
    required this.onChanged,
    required this.lightLabel,
    required this.darkLabel,
    required this.systemLabel,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final String lightLabel;
  final String darkLabel;
  final String systemLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeChip(
          label: lightLabel,
          icon: Icons.light_mode_rounded,
          value: ThemeMode.light,
          current: current,
          onTap: () => onChanged(ThemeMode.light),
        ),
        const SizedBox(width: 10),
        _ThemeChip(
          label: darkLabel,
          icon: Icons.dark_mode_rounded,
          value: ThemeMode.dark,
          current: current,
          onTap: () => onChanged(ThemeMode.dark),
        ),
        const SizedBox(width: 10),
        _ThemeChip(
          label: systemLabel,
          icon: Icons.settings_brightness_rounded,
          value: ThemeMode.system,
          current: current,
          onTap: () => onChanged(ThemeMode.system),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.current,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    final primary = Theme.of(context).colorScheme.primary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final colors = context.appColors;

    return Expanded(
      child: ClayCard(
        elevation: isSelected ? ClayElevation.hero : ClayElevation.low,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        gradient: isSelected
            ? LinearGradient(
                colors: [primary, tertiary],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.white : primary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Amount format option
// ---------------------------------------------------------------------------

class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final AmountFormatStyle value;
  final AmountFormatStyle groupValue;
  final ValueChanged<AmountFormatStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AmountFormatStyle>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
