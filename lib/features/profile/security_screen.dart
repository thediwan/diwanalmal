import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pin_keypad.dart';
import '../../providers/settings_provider.dart';

/// PIN, biometric, recovery code, and app lock settings.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _changingPin = false;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  int _pinStep = 0;
  String? _pinError;

  Future<void> _toggleBiometric(bool enabled, SettingsProvider settings) async {
    if (enabled) {
      final ok = await settings.promptBiometricSetup();
      if (!mounted) return;
      if (ok) {
        await settings.setBiometricEnabled(true);
        if (!mounted) return;
        context.showSuccessFeedback(context.l10n.authFingerprintSuccess);
      } else {
        context.showErrorFeedback(context.l10n.authFingerprintError);
      }
    } else {
      await settings.setBiometricEnabled(false);
    }
  }

  void _startPinChange() {
    setState(() {
      _changingPin = true;
      _pinStep = 0;
      _currentPin = '';
      _newPin = '';
      _confirmPin = '';
      _pinError = null;
    });
  }

  void _cancelPinChange() {
    setState(() {
      _changingPin = false;
      _pinError = null;
    });
  }

  void _onPinDigit(String digit) {
    setState(() {
      _pinError = null;
      if (_pinStep == 0 && _currentPin.length < 4) {
        _currentPin += digit;
      } else if (_pinStep == 1 && _newPin.length < 4) {
        _newPin += digit;
      } else if (_pinStep == 2 && _confirmPin.length < 4) {
        _confirmPin += digit;
      }
    });

    if (_pinStep == 0 && _currentPin.length == 4) _verifyCurrentPin();
    if (_pinStep == 1 && _newPin.length == 4) {
      setState(() => _pinStep = 2);
    }
    if (_pinStep == 2 && _confirmPin.length == 4) _saveNewPin();
  }

  void _onPinBackspace() {
    setState(() {
      _pinError = null;
      if (_pinStep == 0 && _currentPin.isNotEmpty) {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      } else if (_pinStep == 1 && _newPin.isNotEmpty) {
        _newPin = _newPin.substring(0, _newPin.length - 1);
      } else if (_pinStep == 2 && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  void _verifyCurrentPin() {
    final settings = context.read<SettingsProvider>();
    if (!settings.validatePin(_currentPin)) {
      setState(() {
        _pinError = context.l10n.profilePinInvalid;
        _currentPin = '';
      });
      return;
    }
    setState(() => _pinStep = 1);
  }

  Future<void> _saveNewPin() async {
    if (_newPin != _confirmPin) {
      setState(() {
        _pinError = context.l10n.profilePinMismatch;
        _confirmPin = '';
      });
      return;
    }

    await context.read<SettingsProvider>().updatePin(_newPin);
    if (!mounted) return;
    context.showSuccessFeedback(context.l10n.profilePinUpdated);
    _cancelPinChange();
  }

  String get _pinStepLabel {
    final l10n = context.l10n;
    return switch (_pinStep) {
      0 => l10n.profileCurrentPin,
      1 => l10n.profileNewPin,
      _ => l10n.profileConfirmPin,
    };
  }

  int get _activePinLength {
    return switch (_pinStep) {
      0 => _currentPin.length,
      1 => _newPin.length,
      _ => _confirmPin.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileSecurity),
        leading: _changingPin
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelPinChange,
              )
            : null,
      ),
      body: _changingPin
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _pinStepLabel,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.dashboardPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PinDots(length: _activePinLength),
                  if (_pinError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _pinError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                  const Spacer(),
                  PinKeypad(
                    onDigit: _onPinDigit,
                    onBackspace: _onPinBackspace,
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SwitchListTile(
                  title: Text(l10n.profileBiometric),
                  value: settings.biometricEnabled,
                  activeTrackColor:
                      AppColors.dashboardPrimary.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.dashboardPrimary,
                  onChanged: (v) => _toggleBiometric(v, settings),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(l10n.profileChangePin),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: _startPinChange,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.profileAppLock),
                  subtitle: Text(l10n.profileAppLockSubtitle),
                  onTap: () {
                    settings.lockSession();
                    context.go('/auth/unlock');
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(l10n.profileRecoveryCode),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        settings.securityCode.isNotEmpty
                            ? '••••••'
                            : '—',
                        style: AppTextStyles.bodyLarge.copyWith(
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.profileRecoveryCodeHint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
