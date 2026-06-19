import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/profile_data.dart';

/// Profile avatar, name, and email header block.
///
/// The avatar sits inside a clay ring — a layered shadow circle that
/// creates soft depth around the avatar container.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditAvatar,
  });

  final ProfileData profile;
  final VoidCallback? onEditAvatar;

  static const _avatarSize = 96.0;
  static const _ringWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Clay ring container
            Container(
              width: _avatarSize + _ringWidth * 2,
              height: _avatarSize + _ringWidth * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: isDark ? 8 : 20,
                    offset: Offset(0, isDark ? 4 : 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(_ringWidth),
                child: CircleAvatar(
                  radius: _avatarSize / 2,
                  backgroundColor: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.surfaceElevatedLight,
                  backgroundImage: _avatarImage(profile.avatarPath),
                  child: profile.avatarPath == null ||
                          profile.avatarPath!.isEmpty ||
                          !_fileExists(profile.avatarPath!)
                      ? Text(
                          _initials(profile.displayName),
                          style: AppTextStyles.headingMedium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (onEditAvatar != null)
              Positioned(
                bottom: 0,
                left: 0,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  elevation: isDark ? 0 : 3,
                  shadowColor: isDark
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.45),
                  child: InkWell(
                    onTap: onEditAvatar,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: AppTextStyles.headingSmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (profile.subtitleEmail.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            profile.subtitleEmail,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  static ImageProvider? _avatarImage(String? path) {
    if (path == null || path.isEmpty || !_fileExists(path)) return null;
    return FileImage(File(path));
  }

  static bool _fileExists(String path) => File(path).existsSync();

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
