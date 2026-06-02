import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/settings_provider.dart';

/// Application settings hub.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('العملات'),
            subtitle: Text('العملة الرئيسية: ${settings.baseCurrencyCode}'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/settings/currencies'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('المظهر'),
            subtitle: Text(_themeModeLabel(settings.themeMode)),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('فاتح'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('داكن'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('تلقائي'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('النسخ الاحتياطي'),
            subtitle: const Text('متاح في المرحلة 8'),
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

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'فاتح',
      ThemeMode.dark => 'داكن',
      ThemeMode.system => 'تلقائي',
    };
  }
}
