import 'package:flutter/material.dart';

import '../../../core/constants/treasury_icon_styles.dart';

/// Treasury icon as shown in the wallets list and form pickers.
class TreasuryIcon extends StatelessWidget {
  const TreasuryIcon({
    super.key,
    this.style,
    this.size = 44,
    this.iconSize = 22,
    this.elevated = false,
  });

  final String? style;
  final double size;
  final double iconSize;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final spec = treasuryIconSpecFor(style);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: spec.background,
        borderRadius: BorderRadius.circular(spec.radius),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: spec.foreground.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(
        spec.icon,
        color: spec.foreground,
        size: iconSize,
      ),
    );
  }
}
