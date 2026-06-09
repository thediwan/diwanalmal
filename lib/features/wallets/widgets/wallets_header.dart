import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';

/// Top section for the wallets screen (profile, title, search, add).
class WalletsHeader extends StatelessWidget {
  const WalletsHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddWallet,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddWallet;

  static const _logoAsset = 'assets/images/logo_amanah.png';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ProfileAvatar(onTap: () => context.push('/profile')),
              const SizedBox(width: 8),
              _CircleIconButton(
                icon: CupertinoIcons.bell,
                onPressed: () {},
              ),
              const Spacer(),
              Image.asset(
                _logoAsset,
                width: 88,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  AppConstants.appName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.dashboardPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.walletsTitle,
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.walletsSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: AppFormFields.inputTextStyleOf(context),
                  decoration: AppFormFields.decoration(
                    context,
                    hintText: l10n.walletsSearchHint,
                    fillColor: colors.searchFieldFill,
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: colors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ).copyWith(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: onAddWallet,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dashboardPrimary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  l10n.walletsAddWallet,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dashboardPrimary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            CupertinoIcons.person_crop_circle_fill,
            color: AppColors.dashboardPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: AppColors.dashboardPrimary),
        ),
      ),
    );
  }
}
