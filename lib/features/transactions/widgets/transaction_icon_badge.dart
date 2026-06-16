import 'package:flutter/material.dart';

/// Unified circular icon badge for transaction rows (list + dashboard).
class TransactionIconBadge extends StatelessWidget {
  const TransactionIconBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    this.size = 48,
    this.iconSize = 24,
  });

  final IconData icon;
  final Color iconColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}
