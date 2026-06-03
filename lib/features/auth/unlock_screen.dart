import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/pin_keypad.dart';
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

  void _onDigit(String digit) {
    if (_loading) return;
    setState(() {
      _error = null;
      if (_pin.length < 4) _pin += digit;
    });

    if (_pin.length == 4) _verifyPin();
  }

  void _onBackspace() {
    if (_loading || _pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
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

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
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
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authUnlockSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 28),
                PinDots(length: _pin.length),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.expense),
                  ),
                ],
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
                      icon: const Icon(CupertinoIcons.hand_raised),
                      label: Text(
                        l10n.authUseBiometric,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
