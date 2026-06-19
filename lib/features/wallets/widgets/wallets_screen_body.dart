import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/responsive/responsive_content.dart';
import '../../../core/responsive/responsive_grid.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../models/treasury.dart';
import 'wallet_grid_card.dart';
import 'wallet_list_card.dart';

/// Treasury list that switches between grouped card and responsive grid.
class WalletsTreasuryList extends StatelessWidget {
  const WalletsTreasuryList({
    super.key,
    required this.treasuries,
    this.onEdit,
  });

  final List<Treasury> treasuries;
  final ValueChanged<String>? onEdit;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, sizeClass) {
        final useGrid = isExpandedOrWider(sizeClass);

        if (!useGrid) {
          return WalletsGroupedCard(
            treasuries: treasuries,
            onEdit: onEdit,
          );
        }

        return ResponsiveGrid(
          itemCount: treasuries.length,
          itemBuilder: (context, index) => WalletGridCard(
            treasury: treasuries[index],
            onEdit: onEdit,
          ),
        );
      },
    );
  }
}

/// Scrollable wallets body with responsive content width.
class WalletsScreenBody extends StatelessWidget {
  const WalletsScreenBody({
    super.key,
    required this.header,
    required this.summary,
    required this.treasuries,
    required this.emptySearchMessage,
    required this.onRefresh,
    this.onEdit,
  });

  final Widget header;
  final Widget? summary;
  final List<Treasury> treasuries;
  final String emptySearchMessage;
  final Future<void> Function() onRefresh;
  final ValueChanged<String>? onEdit;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: header),
          if (summary != null) SliverToBoxAdapter(child: summary!),
          if (treasuries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(emptySearchMessage),
              ),
            )
          else
            SliverToBoxAdapter(
              child: ResponsiveContent(
                maxWidth: AppBreakpoints.contentMaxLarge,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  child: WalletsTreasuryList(
                    treasuries: treasuries,
                    onEdit: onEdit,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
