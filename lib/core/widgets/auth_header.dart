import 'package:flutter/material.dart';

import '../extensions/context_l10n.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../theme/app_text_styles.dart';
import 'brand_logo.dart';

/// Top branding block used on auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.showTagline = true,
    this.compact = false,
    this.tagline,
  });

  final bool showTagline;
  final bool compact;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BrandLogoTile(size: 40),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const BrandLogoTile(size: 72),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.primaryContainer,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            tagline ?? context.l10n.appTagline,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }
}
