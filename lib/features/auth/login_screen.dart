import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/split_auth_background.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../core/widgets/auth_header.dart';
import '../../providers/settings_provider.dart';
import '../../core/extensions/context_feedback.dart';

/// Email/password sign in screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _remember = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = context.read<SettingsProvider>();
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (!settings.validateLogin(username, password)) {
      context.showErrorFeedback(context.l10n.authInvalidCredentials);
      return;
    }

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _loading = false);

    if (!settings.isSecuritySetupComplete) {
      context.go('/auth/setup-lock');
      return;
    }

    if (settings.needsSecurityCodeScreen) {
      context.go('/auth/security-code');
      return;
    }

    context.go('/auth/unlock');
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
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const AuthHeader(),
                const SizedBox(height: 28),
                AuthFormCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.authLoginTitle,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.authLoginSubtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          l10n.authEmailOrPhone,
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          style: inputStyle,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: l10n.authEmailHint,
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: colors.inputHint,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.person,
                              color: colors.textSecondary,
                            ),
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? l10n.fieldRequired
                              : null,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  context.push('/auth/reset-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                l10n.authForgotPassword,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(l10n.authPassword, style: AppTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          style: inputStyle,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              CupertinoIcons.lock,
                              color: colors.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                color: colors.textSecondary,
                              ),
                            ),
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value == null || value.length < 6
                              ? l10n.authInvalidPassword
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              activeColor: AppColors.primaryContainer,
                              onChanged: (v) => setState(() => _remember = v ?? false),
                            ),
                            Text(
                              l10n.authRememberDevice,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
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
                                      Text(l10n.login, style: AppTextStyles.bodyLarge),
                                      const SizedBox(width: 8),
                                      const Icon(CupertinoIcons.arrow_left, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: () => context.go('/auth/register'),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: l10n.authNoAccount),
                        TextSpan(
                          text: l10n.authCreateAccountLink,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
