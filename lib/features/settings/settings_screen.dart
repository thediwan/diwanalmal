import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/settings_provider.dart';

/// Application settings hub.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(l10n.settingsCurrencies),
            subtitle: Text(l10n.settingsBaseCurrency(settings.baseCurrencyCode)),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/settings/currencies'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.settingsAppearance),
            subtitle: Text(switch (settings.themeMode) {
              ThemeMode.light => l10n.settingsThemeLight,
              ThemeMode.dark => l10n.settingsThemeDark,
              ThemeMode.system => l10n.settingsThemeSystem,
            }),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeLight),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeDark),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeSystem),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.settingsAppLock),
            subtitle: Text(l10n.settingsAppLockSubtitle),
            onTap: () {
              settings.lockSession();
              context.go('/auth/unlock');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.settingsBackup),
            subtitle: Text(l10n.settingsBackupSubtitle),
            enabled: false,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
