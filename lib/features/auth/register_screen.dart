import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/auth_header.dart';
import '../../providers/settings_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        tagline: 'ننمو معك بذكاء وأمان',
                      ),
                      const SizedBox(height: 28),
                      _fieldLabel('اسم المستخدم'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: _inputDecoration('أدخل اسمك الكامل'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
                      ),
                      const SizedBox(height: 18),
                      _fieldLabel('كلمة المرور'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(null).copyWith(
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
                            return 'كلمة المرور قصيرة جداً';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _fieldLabel('تأكيد كلمة المرور'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: _inputDecoration(null).copyWith(
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
                            return 'كلمتا المرور غير متطابقتين';
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
                            activeColor: AppColors.primaryContainer,
                            onChanged: (v) =>
                                setState(() => _acceptedTerms = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'بإنشاء حساب، أنت توافق على ',
                                    ),
                                    TextSpan(
                                      text: 'الشروط والأحكام',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' و '),
                                    TextSpan(
                                      text: 'سياسة الخصوصية',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primaryContainer,
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
                                    Text('إنشاء حساب', style: AppTextStyles.bodyLarge),
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
                                color: AppColors.textSecondaryLight,
                              ),
                              children: [
                                const TextSpan(text: 'لديك حساب بالفعل؟ '),
                                TextSpan(
                                  text: 'تسجيل الدخول',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryContainer,
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
                  backgroundColor: Colors.white,
                  child: const Icon(
                    CupertinoIcons.question,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            ],
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

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
