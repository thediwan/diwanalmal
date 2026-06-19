import 'package:flutter/material.dart';

import '../../../core/extensions/context_theme.dart';
import '../../../models/treasury.dart';
import 'wallet_list_card.dart';

/// Single treasury card for responsive grid layouts.
class WalletGridCard extends StatelessWidget {
  const WalletGridCard({
    super.key,
    required this.treasury,
    this.onEdit,
  });

  final Treasury treasury;
  final ValueChanged<String>? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: WalletListItem(
        treasury: treasury,
        onEdit: onEdit,
      ),
    );
  }
}
