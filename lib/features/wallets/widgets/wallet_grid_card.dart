import 'package:flutter/material.dart';

import '../../../core/widgets/clay_card.dart';
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
    return ClayCard(
      elevation: ClayElevation.standard,
      padding: EdgeInsets.zero,
      child: WalletListItem(
        treasury: treasury,
        onEdit: onEdit,
      ),
    );
  }
}
