import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/split_auth_background.dart';
import '../../core/widgets/auth_header.dart';
import '../../providers/settings_provider.dart';
import '../../core/extensions/context_feedback.dart';

/// Create account screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      context.showWarningFeedback(context.l10n.authTermsRequired);
      return;
    }

    setState(() => _loading = true);

    final settings = context.read<SettingsProvider>();

    try {
      await settings.registerAccount(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() => _loading = false);
      context.go('/auth/setup-lock');
    } catch (e) {
      if (mounted) {
        context.showOperationError(e);
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final inputStyle = AppFormFields.inputTextStyleOf(context);

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: ResponsiveAuthLayout(
            child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(tagline: l10n.authRegisterTagline),
                      const SizedBox(height: 28),
                      _fieldLabel(l10n.authUsername),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        style: inputStyle,
                        decoration: _inputDecoration(context, l10n.authUsernameHint),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? l10n.authNameRequired : null,
                      ),
                      const SizedBox(height: 18),
                      _fieldLabel(l10n.authPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        style: inputStyle,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(context, null).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return l10n.authPasswordShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _fieldLabel(l10n.authConfirmPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: inputStyle,
                        obscureText: _obscureConfirm,
                        decoration: _inputDecoration(context, null).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return l10n.authPasswordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (v) =>
                                setState(() => _acceptedTerms = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l10n.authTermsPrefix,
                                    ),
                                    TextSpan(
                                      text: l10n.authTerms,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: l10n.authTermsAnd),
                                    TextSpan(
                                      text: l10n.authPrivacy,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading ? null : _submit,
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
                                    Text(l10n.authCreateAccount, style: AppTextStyles.bodyLarge),
                                    const SizedBox(width: 8),
                                    const Icon(CupertinoIcons.arrow_right, size: 20),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/auth/login'),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: l10n.authHasAccount),
                                TextSpan(
                                  text: l10n.login,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
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
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  onPressed: () {},
                  backgroundColor: colors.surface,
                  child: Icon(
                    CupertinoIcons.question,
                    color: Theme.of(context).colorScheme.primary,
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

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text, style: AppTextStyles.label),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String? hint) {
    final colors = context.appColors;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.inputHint),
      filled: true,
      fillColor: colors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.inputBorder),
      ),
    );
  }
}
