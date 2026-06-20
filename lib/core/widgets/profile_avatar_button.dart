import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

/// Tappable circular avatar for app headers — shows the user's profile photo
/// from [ProfileProvider], or initials / a default icon as fallback.
class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({
    super.key,
    required this.onTap,
    this.size = 40,
    this.filled = true,
  });

  final VoidCallback onTap;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final primary = Theme.of(context).colorScheme.primary;
    final avatarPath = profile?.avatarPath;
    final displayName = profile?.displayName ?? '';

    return Material(
      color: filled ? primary.withValues(alpha: 0.12) : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: _AvatarContent(
            avatarPath: avatarPath,
            displayName: displayName,
            primary: primary,
            size: size,
          ),
        ),
      ),
    );
  }
}

class _AvatarContent extends StatelessWidget {
  const _AvatarContent({
    required this.avatarPath,
    required this.displayName,
    required this.primary,
    required this.size,
  });

  final String? avatarPath;
  final String displayName;
  final Color primary;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (avatarPath != null &&
        avatarPath!.isNotEmpty &&
        File(avatarPath!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(avatarPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    final initials = _initials(displayName);
    if (initials != '?') {
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      );
    }

    return Icon(
      CupertinoIcons.person_crop_circle_fill,
      color: primary,
      size: size * 0.68,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
