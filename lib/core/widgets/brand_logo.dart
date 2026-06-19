import 'package:flutter/material.dart';

import '../constants/brand_logo_assets.dart';
import '../extensions/context_theme.dart';
import '../theme/app_text_styles.dart';

/// Theme-aware brand logo image.
class BrandLogoImage extends StatelessWidget {
  const BrandLogoImage({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorBuilder,
  });

  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandLogoAssets.forContext(context),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}

/// Full AMANAH wordmark logo (splash).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 56});

  final double height;

  @override
  Widget build(BuildContext context) {
    return BrandLogoImage(
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: BrandLogoImage(
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.account_balance,
          size: size * 0.45,
          color: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(context).colorScheme.primary,
        fontSize: height * 0.55,
        letterSpacing: 1.2,
      ),
    );
  }
}
