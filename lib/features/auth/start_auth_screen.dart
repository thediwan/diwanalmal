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
import '../../core/widgets/auth_header.dart';
import '../../providers/settings_provider.dart';
import '../../core/extensions/context_feedback.dart';

/// Biometric start screen before login.
class StartAuthScreen extends StatefulWidget {
  const StartAuthScreen({super.key});

  @override
  State<StartAuthScreen> createState() => _StartAuthScreenState();
}

class _StartAuthScreenState extends State<StartAuthScreen> {
  bool _loading = false;

  Future<void> _startBiometric() async {
    final settings = context.read<SettingsProvider>();

    if (!settings.hasAccount) {
      context.go('/auth/register');
      return;
    }

    if (!settings.biometricEnabled) {
      context.go('/auth/unlock');
      return;
    }

    setState(() => _loading = true);
    final ok = await settings.authenticateWithBiometric();
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      if (settings.needsSecurityCodeScreen) {
        context.go('/auth/security-code');
      } else if (settings.isSetupComplete) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    } else {
      context.showErrorFeedback(context.l10n.authBiometricFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsProvider>();
    final hasAccount = settings.hasAccount;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const AuthHeader(compact: true),
                const SizedBox(height: 24),
                AuthFormCard(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              CupertinoIcons.hand_raised,
                              size: 52,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          Positioned(
                            top: -4,
                            left: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.checkmark_shield_fill,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        hasAccount ? l10n.authWelcomeBack : l10n.authWelcome,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hasAccount
                            ? l10n.authStartWithAccount(AppConstants.appName)
                            : l10n.authStartNoAccount,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading ? null : _startBiometric,
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(CupertinoIcons.person_crop_circle),
                          label: Text(
                            hasAccount ? l10n.authStartBiometric : l10n.authCreateAccount,
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryContainer,
                            side: BorderSide(
                              color: AppColors.primaryContainer.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (hasAccount) {
                              context.go('/auth/unlock');
                            } else {
                              context.go('/auth/login');
                            }
                          },
                          icon: const Icon(CupertinoIcons.lock),
                          label: Text(
                            hasAccount ? l10n.authUsePin : l10n.authUsePassword,
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ),
                      if (!hasAccount) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/auth/register'),
                          child: Text(
                            l10n.authCreateAccountNew,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_shield,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.authBankGradeSecurity,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.authCopyright,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
