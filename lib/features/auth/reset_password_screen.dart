import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/split_auth_background.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../providers/settings_provider.dart';
import '../../core/extensions/context_feedback.dart';

/// Resets account password using the offline recovery security code.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _securityCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _securityCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;

    var score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    return score.clamp(0, 4);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = context.read<SettingsProvider>();
    if (!settings.hasAccount) {
      _showMessage(context.l10n.authNoAccountOnDevice);
      return;
    }

    setState(() => _loading = true);

    try {
      final ok = await settings.resetPassword(
        securityCode: _securityCodeController.text,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      if (!ok) {
        _showMessage(context.l10n.authWrongSecurityCode);
        return;
      }

      _showMessage(context.l10n.authPasswordChanged);
      context.go('/auth/login');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String text) {
    context.showWarningFeedback(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final hasAccount = context.watch<SettingsProvider>().hasAccount;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: ResponsiveAuthLayout(
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(CupertinoIcons.arrow_right),
                      color: colors.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.lock_rotation,
                            size: 44,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          l10n.authResetPassword,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.authResetPasswordDesc,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            height: 1.55,
                          ),
                        ),
                        if (!hasAccount) ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n.authNoLocalAccount,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        AuthFormCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _labeledField(
                                context: context,
                                label: l10n.authSecurityCode,
                                child: TextFormField(
                                  controller: _securityCodeController,
                                  enabled: hasAccount,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.center,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9]'),
                                    ),
                                    UpperCaseTextFormatter(),
                                  ],
                                  style: AppTextStyles.headingSmall.copyWith(
                                    color: AppColors.primaryContainer,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                  ),
                                  decoration: _fieldDecoration(
                                    context,
                                    suffixIcon: const Icon(
                                      CupertinoIcons.shield_fill,
                                      color: AppColors.primaryContainer,
                                      size: 22,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().length != 6) {
                                      return l10n.authSecurityCodeInvalid;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
                              _labeledField(
                                context: context,
                                label: l10n.authNewPassword,
                                child: TextFormField(
                                  controller: _passwordController,
                                  enabled: hasAccount,
                                  obscureText: _obscurePassword,
                                  onChanged: (_) => setState(() {}),
                                  decoration: _fieldDecoration(
                                    context,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword,
                                      ),
                                      icon: Icon(
                                        _obscurePassword
                                            ? CupertinoIcons.eye
                                            : CupertinoIcons.eye_slash,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      CupertinoIcons.lock_fill,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.length < 6) {
                                      return l10n.authNewPasswordShort;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              _PasswordStrengthBar(strength: _passwordStrength),
                              const SizedBox(height: 18),
                              _labeledField(
                                context: context,
                                label: l10n.authConfirmNewPassword,
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  enabled: hasAccount,
                                  obscureText: _obscureConfirm,
                                  decoration: _fieldDecoration(
                                    context,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm,
                                      ),
                                      icon: Icon(
                                        _obscureConfirm
                                            ? CupertinoIcons.eye
                                            : CupertinoIcons.eye_slash,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.vpn_key_outlined,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v != _passwordController.text) {
                                      return l10n.authPasswordMismatch;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed:
                                hasAccount && !_loading ? _submit : null,
                            child: _loading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_left,
                                        size: 20,
                                        color: colors.onPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.authResetPassword,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: colors.onPrimary,
                                          fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField({
    required BuildContext context,
    required String label,
    required Widget child,
  }) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final colors = context.appColors;

    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: colors.inputHint,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colors.inputFill,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryContainer,
          width: 1.5,
        ),
      ),
    );
  }
}

/// Four-segment password strength indicator.
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final int strength;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: List.generate(4, (index) {
        final filled = index < strength;
        Color color;
        if (!filled) {
          color = colors.inputBorder;
        } else if (strength <= 2) {
          color = AppColors.warning;
        } else if (strength == 3) {
          color = AppColors.primaryContainer;
        } else {
          color = AppColors.success;
        }

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Forces uppercase for security code input.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
