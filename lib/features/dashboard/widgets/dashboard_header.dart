import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';

/// Dashboard top bar: logo (visual left), centered title, bell + profile (visual right).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  static const _logoAsset = 'assets/images/logo_amanah.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _HeaderIconButton(
            onPressed: () {},
            icon: CupertinoIcons.bell,
          ),
          const SizedBox(width: 6),
          _HeaderIconButton(
            onPressed: () => context.push('/profile'),
            icon: CupertinoIcons.person_crop_circle,
            filled: true,
          ),
          Expanded(
            child: Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.dashboardPrimary,
                fontSize: 20,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _logoAsset,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_balance,
                size: 30,
                color: AppColors.dashboardPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onPressed,
    required this.icon,
    this.filled = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? AppColors.dashboardPrimary.withValues(alpha: 0.12)
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: AppColors.dashboardPrimary,
          ),
        ),
      ),
    );
  }
}
