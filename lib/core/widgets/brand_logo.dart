import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full AMANAH wordmark logo (splash).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 56});

  final double height;

  static const _assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _FallbackWordmark(height: height),
    );
  }
}

/// Square tile logo with AMANA label (login header).
class BrandLogoTile extends StatelessWidget {
  const BrandLogoTile({super.key, this.size = 72});

  final double size;

  static const _assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Image.asset(
        _assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.account_balance,
          size: size * 0.45,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }
}

class _FallbackWordmark extends StatelessWidget {
  const _FallbackWordmark({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Text(
      'AMANAH',
      style: AppTextStyles.headingMedium.copyWith(
        color: AppColors.primaryContainer,
        fontSize: height * 0.55,
        letterSpacing: 1.2,
      ),
    );
  }
}
