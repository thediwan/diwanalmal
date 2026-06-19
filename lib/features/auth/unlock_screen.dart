import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/pin_keypad.dart';
import '../../core/widgets/split_auth_background.dart';
import '../../providers/settings_provider.dart';

/// App lock screen — requires PIN or biometric to continue.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  String _pin = '';
  String? _error;
  bool _loading = false;
  bool _hasError = false;

  void _onDigit(String digit) {
    if (_loading) return;
    setState(() {
      _error = null;
      _hasError = false;
      if (_pin.length < 4) _pin += digit;
    });

    if (_pin.length == 4) _verifyPin();
  }

  void _onBackspace() {
    if (_loading || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
      _hasError = false;
    });
  }

  void _verifyPin() {
    final settings = context.read<SettingsProvider>();
    if (settings.validatePin(_pin)) {
      settings.unlockSession();
      _goNext();
      return;
    }

    setState(() {
      _error = context.l10n.authPinInvalid;
      _hasError = true;
      _pin = '';
    });
  }

  Future<void> _tryBiometric() async {
    setState(() => _loading = true);
    final settings = context.read<SettingsProvider>();
    final ok = await settings.authenticateWithBiometric();
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      _goNext();
    } else {
      setState(() => _error = context.l10n.authBiometricSetupFailed);
    }
  }

  void _goNext() {
    final settings = context.read<SettingsProvider>();
    if (settings.needsSecurityCodeScreen) {
      context.go('/auth/security-code');
    } else if (settings.isSetupComplete) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsProvider>();
    final colors = context.appColors;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: ResponsiveAuthLayout(
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const BrandLogo(height: 48),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authUnlockSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                PinDots(
                  length: _pin.length,
                  hasError: _hasError,
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _error != null ? 1.0 : 0.0,
                  child: Text(
                    _error ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.expense,
                    ),
                  ),
                ),
                // Offline trust badge
                const SizedBox(height: 8),
                _OfflineTrustBadge(),
                const SizedBox(height: 24),
                Expanded(
                  child: AuthFormCard(
                    padding: const EdgeInsets.all(16),
                    child: PinKeypad(
                      onDigit: _onDigit,
                      onBackspace: _onBackspace,
                    ),
                  ),
                ),
                if (settings.biometricEnabled) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _tryBiometric,
                      icon: Icon(
                        CupertinoIcons.hand_raised_fill,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        l10n.authUseBiometric,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_loading)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

/// Small offline trust indicator — communicates offline-first data safety.
class _OfflineTrustBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 12,
          color: AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          l10n.statusOfflineData,
          style: AppTextStyles.labelSmall.copyWith(
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
