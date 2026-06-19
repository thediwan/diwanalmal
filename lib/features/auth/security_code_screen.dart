import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../core/widgets/split_auth_background.dart';
import '../../providers/settings_provider.dart';
import '../../core/extensions/context_feedback.dart';

/// Shows recovery security code after PIN and biometric setup.
class SecurityCodeScreen extends StatelessWidget {
  const SecurityCodeScreen({super.key, required this.securityCode});

  final String securityCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    if (securityCode.isEmpty) {
      return Scaffold(
        body: SplitAuthBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.authSecurityCodeLoadError,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final chars = securityCode.split('');

    return Scaffold(
      body: SplitAuthBackground(
        child: SafeArea(
          child: ResponsiveAuthLayout(
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.check_mark,
                      color: colors.onPrimary,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.authAccountCreated,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.authSecurityCodeHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    height: 1.55,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),
                AuthFormCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.authYourSecurityCode,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 22),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const boxSpacing = 8.0;
                          final count = chars.length;
                          final maxBoxWidth = count > 0
                              ? (constraints.maxWidth -
                                      (count - 1) * boxSpacing) /
                                  count
                              : 46.0;
                          final boxWidth = maxBoxWidth.clamp(36.0, 46.0);
                          final fontSize =
                              (boxWidth * 0.48).clamp(16.0, 22.0);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < chars.length; i++) ...[
                                if (i > 0) const SizedBox(width: boxSpacing),
                                Container(
                                  width: boxWidth,
                                  height: 54,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.inputBorder,
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.cardShadow,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    chars[i],
                                    style:
                                        AppTextStyles.headingSmall.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          backgroundColor: colors.surfaceVariant,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: securityCode),
                          );
                          context.showSuccessFeedback(l10n.authCodeCopied);
                        },
                        icon: Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        label: Text(
                          l10n.authCopyCode,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.expense.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: AppColors.expense,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.authSecurityWarning,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.expense,
                            height: 1.55,
                            fontSize: 13,
                          ),
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await context
                          .read<SettingsProvider>()
                          .acknowledgeSecurityCode();
                      if (!context.mounted) return;
                      context.go('/onboarding');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.next,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.arrow_left,
                          size: 20,
                          color: colors.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.authGoToCurrency,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 13,
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
