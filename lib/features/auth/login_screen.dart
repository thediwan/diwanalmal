import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../core/widgets/auth_header.dart';
import '../../providers/settings_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
      );
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
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
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
                          'تسجيل الدخول',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'أدخل بياناتك للوصول إلى حسابك',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'البريد الإلكتروني أو الهاتف',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: 'example@mail.com',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                            prefixIcon: const Icon(
                              CupertinoIcons.person,
                              color: AppColors.textSecondaryLight,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF2F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'الحقل مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text('كلمة المرور', style: AppTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              CupertinoIcons.lock,
                              color: AppColors.textSecondaryLight,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF2F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value == null || value.length < 6
                              ? 'كلمة المرور غير صالحة'
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
                              'تذكرني على هذا الجهاز',
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
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('دخول', style: AppTextStyles.bodyLarge),
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
                        color: AppColors.textSecondaryLight,
                      ),
                      children: [
                        const TextSpan(text: 'ليس لديك حساب؟ '),
                        TextSpan(
                          text: 'أنشئ حساباً جديداً',
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
    );
  }
}
