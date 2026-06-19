import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/amount_format_style.dart';
import '../../providers/settings_provider.dart';

/// Theme, amount format, and advanced appearance options.
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
          Text(
            l10n.settingsAppearance,
            style: AppTextStyles.label.copyWith(
              color: AppColors.dashboardPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeLight),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            activeColor: AppColors.dashboardPrimary,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeDark),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            activeColor: AppColors.dashboardPrimary,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeSystem),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            activeColor: AppColors.dashboardPrimary,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsAmountFormat,
            style: AppTextStyles.label.copyWith(
              color: AppColors.dashboardPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsAmountFormatSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<AmountFormatStyle>(
            title: Text(l10n.settingsAmountFormatWestern),
            value: AmountFormatStyle.western,
            groupValue: settings.amountFormatStyle,
            activeColor: AppColors.dashboardPrimary,
            onChanged: (v) {
              if (v != null) settings.setAmountFormatStyle(v);
            },
          ),
          RadioListTile<AmountFormatStyle>(
            title: Text(l10n.settingsAmountFormatEuropean),
            value: AmountFormatStyle.european,
            groupValue: settings.amountFormatStyle,
            activeColor: AppColors.dashboardPrimary,
            onChanged: (v) {
              if (v != null) settings.setAmountFormatStyle(v);
            },
          ),
          RadioListTile<AmountFormatStyle>(
            title: Text(l10n.settingsAmountFormatPlain),
            value: AmountFormatStyle.plain,
            groupValue: settings.amountFormatStyle,
            activeColor: AppColors.dashboardPrimary,
            onChanged: (v) {
              if (v != null) settings.setAmountFormatStyle(v);
            },
          ),
        ],
      ),
    );
  }
}
