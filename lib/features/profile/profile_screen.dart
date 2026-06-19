import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/responsive_content.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/currency_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_settings_section.dart';
import 'widgets/profile_settings_tile.dart';

/// Unified profile and settings hub at `/settings`.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _appVersion;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
      _loadVersion();
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = info.version);
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    try {
      await context.read<ProfileProvider>().updateAvatar(picked.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileAvatarUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showLanguageSheet() {
    final l10n = context.l10n;
    final settings = context.read<SettingsProvider>();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.profileSelectLanguage),
                titleTextStyle: AppTextStyles.headingSmall,
              ),
              RadioListTile<Locale>(
                title: Text(l10n.profileLanguageArabic),
                value: const Locale('ar'),
                groupValue: settings.locale,
                onChanged: (v) async {
                  if (v == null) return;
                  await settings.setLocale(v);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              RadioListTile<Locale>(
                title: Text(l10n.profileLanguageEnglish),
                value: const Locale('en'),
                groupValue: settings.locale,
                onChanged: (v) async {
                  if (v == null) return;
                  await settings.setLocale(v);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final settings = context.watch<SettingsProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final baseCurrency = context.watch<CurrencyProvider>().baseCurrency;

    final currencySubtitle = baseCurrency != null
        ? '${baseCurrency.name} (${baseCurrency.code})'
        : settings.baseCurrencyCode;

    final isDarkMode = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: profileProvider.isLoading && profileProvider.profile == null
            ? const Center(child: CircularProgressIndicator())
            : ResponsiveContent(
                child: RefreshIndicator(
                  onRefresh: () => profileProvider.load(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                    children: [
                    if (profileProvider.profile != null)
                      ProfileHeader(
                        profile: profileProvider.profile!,
                        onEditAvatar: _pickAvatar,
                      )
                    else
                      const SizedBox(height: 120),
                    const SizedBox(height: 28),
                    ProfileSettingsSection(
                      title: l10n.profileSectionAccount,
                      children: [
                        ProfileSettingsTile(
                          icon: Icons.person_outline,
                          title: l10n.profilePersonalInfo,
                          onTap: () =>
                              context.push('/settings/personal-info'),
                        ),
                        ProfileSettingsTile(
                          icon: Icons.shield_outlined,
                          title: l10n.profileSecurity,
                          onTap: () => context.push('/settings/security'),
                        ),
                        ProfileSettingsTile(
                          icon: Icons.vpn_key_outlined,
                          title: l10n.profileTwoFactor,
                          subtitle: l10n.profileTwoFactorSubtitle,
                          enabled: false,
                          showChevron: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProfileSettingsSection(
                      title: l10n.profileSectionFinancial,
                      children: [
                        ProfileSettingsTile(
                          icon: Icons.payments_outlined,
                          title: l10n.profileDefaultCurrency,
                          subtitle: currencySubtitle,
                          onTap: () =>
                              context.push('/settings/currencies'),
                        ),
                        ProfileSettingsTile(
                          icon: Icons.language,
                          title: l10n.profileLanguage,
                          subtitle: settings.locale.languageCode == 'en'
                              ? l10n.profileLanguageEnglish
                              : l10n.profileLanguageArabic,
                          onTap: _showLanguageSheet,
                        ),
                        ProfileSettingsTile(
                          icon: Icons.notifications_outlined,
                          title: l10n.profileNotifications,
                          subtitle: l10n.profileNotificationsSubtitle,
                          enabled: false,
                          showChevron: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProfileSettingsSection(
                      title: l10n.profileSectionAppearance,
                      children: [
                        ProfileSettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: l10n.profileDarkMode,
                          showChevron: false,
                          trailing: Switch.adaptive(
                            value: isDarkMode,
                            activeTrackColor:
                                AppColors.dashboardPrimary.withValues(alpha: 0.5),
                            activeThumbColor: AppColors.dashboardPrimary,
                            onChanged: (on) {
                              settings.setThemeMode(
                                on ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                          ),
                        ),
                        ProfileSettingsTile(
                          icon: Icons.palette_outlined,
                          title: l10n.profileAppearanceCustomize,
                          onTap: () =>
                              context.push('/settings/appearance'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ProfileLogoutButton(
                      label: l10n.profileLogout,
                      confirmTitle: l10n.profileLogoutConfirmTitle,
                      confirmMessage: l10n.profileLogoutConfirmMessage,
                      onConfirm: () {
                        settings.lockSession();
                        context.go('/auth/unlock');
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_appVersion != null)
                      Text(
                        l10n.profileVersion(
                          AppConstants.appName,
                          _appVersion!,
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
