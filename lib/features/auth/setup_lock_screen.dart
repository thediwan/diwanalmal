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
import '../../core/widgets/pin_keypad.dart';
import '../../providers/settings_provider.dart';

/// PIN and biometric setup after registration.
class SetupLockScreen extends StatefulWidget {
  const SetupLockScreen({super.key});

  @override
  State<SetupLockScreen> createState() => _SetupLockScreenState();
}

class _SetupLockScreenState extends State<SetupLockScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _checkingBiometric = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometric());
  }

  Future<void> _checkBiometric() async {
    final available = await context.read<SettingsProvider>().canUseBiometric();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _checkingBiometric = false;
    });
  }

  Future<void> _setupBiometric() async {
    final ok = await context.read<SettingsProvider>().promptBiometricSetup();
    if (!mounted) return;

    if (ok) {
      setState(() {
        _biometricEnabled = true;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authFingerprintSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authFingerprintError)),
      );
    }
  }

  void _onDigit(String digit) {
    if (_saving) return;
    setState(() {
      _error = null;
      final target = _isConfirmStep ? _confirmPin : _pin;
      if (target.length < 4) {
        if (_isConfirmStep) {
          _confirmPin += digit;
        } else {
          _pin += digit;
        }
      }
    });
  }

  void _onBackspace() {
    if (_saving) return;
    setState(() {
      _error = null;
      if (_isConfirmStep) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirmStep = false;
        }
      } else if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _savePin() async {
    final l10n = context.l10n;

    if (_pin.length < 4) {
      setState(() => _error = l10n.authPinMinDigits);
      return;
    }

    if (!_isConfirmStep) {
      setState(() => _isConfirmStep = true);
      return;
    }

    if (_pin != _confirmPin) {
      setState(() {
        _error = l10n.authPinMismatch;
        _pin = '';
        _confirmPin = '';
        _isConfirmStep = false;
      });
      return;
    }

    setState(() => _saving = true);

    final settings = context.read<SettingsProvider>();

    try {
      final code = await settings.completeSecuritySetup(
        pinCode: _pin,
        enableBiometric: _biometricAvailable && _biometricEnabled,
      );

      if (!mounted) return;

      if (code.isEmpty) {
        setState(() {
          _saving = false;
          _error = l10n.authSecurityCodeFailed;
        });
        return;
      }

      setState(() => _saving = false);

      if (!mounted) return;
      context.go('/auth/security-code', extra: code);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.errorGeneric;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pinLength = _isConfirmStep ? _confirmPin.length : _pin.length;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/auth/register'),
                      icon: const Icon(CupertinoIcons.arrow_right),
                    ),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      if (_biometricAvailable) ...[
                        AuthFormCard(
                          child: Column(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryContainer
                                        .withValues(alpha: 0.35),
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.hand_raised,
                                  size: 44,
                                  color: _biometricEnabled
                                      ? AppColors.success
                                      : AppColors.primaryContainer,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.authFingerprint,
                                style: AppTextStyles.headingSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.authFingerprintDesc,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryContainer,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      _checkingBiometric ? null : _setupBiometric,
                                  child: Text(
                                    _biometricEnabled
                                        ? l10n.authFingerprintDone
                                        : l10n.authSetupFingerprint,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AuthFormCard(
                        child: Column(
                          children: [
                            PinDots(length: pinLength),
                            const SizedBox(height: 16),
                            Text(
                              _isConfirmStep
                                  ? l10n.authPinReenter
                                  : l10n.authPinPersonal,
                              style: AppTextStyles.headingSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isConfirmStep
                                  ? l10n.authPinConfirmHint
                                  : l10n.authPinEnterHint,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_checkingBiometric)
                              const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              PinKeypad(
                                onDigit: _onDigit,
                                onBackspace: _onBackspace,
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryContainer,
                                  side: const BorderSide(
                                    color: AppColors.primaryContainer,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _saving ? null : _savePin,
                                child: _saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        l10n.authSavePin,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
