import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/profile_avatar_button.dart';

/// Dashboard top bar: logo (visual left), centered title, bell + profile (visual right).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _HeaderIconButton(
            onPressed: () {},
            icon: CupertinoIcons.bell,
          ),
          const SizedBox(width: 6),
          ProfileAvatarButton(
            onTap: () => context.push('/settings'),
            size: 44,
          ),
          Expanded(
            child: Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: primary,
                fontSize: 20,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.iconBadge),
            child: BrandLogoImage(
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.account_balance,
                size: 30,
                color: primary,
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
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: primary,
          ),
        ),
      ),
    );
  }
}
