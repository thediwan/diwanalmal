import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/wallet_provider.dart';
import 'widgets/wallet_list_card.dart';
import 'widgets/wallets_header.dart';
import 'widgets/wallets_summary_section.dart';

/// Treasuries list with summary, search, and currency breakdown per card.
class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<WalletProvider>().loadWallets();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _openAddWallet() {
    context.push('/wallets/add');
  }

  void _openEditWallet(String treasuryId) {
    context.push('/wallets/$treasuryId/edit');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.treasuries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = provider.summary;
          final filtered = provider.filterTreasuries(_searchQuery);

          if (provider.treasuries.isEmpty) {
            return Column(
              children: [
                WalletsHeader(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  onAddWallet: _openAddWallet,
                ),
                Expanded(
                  child: EmptyState(
                    message: l10n.walletsEmpty,
                    icon: Icons.account_balance_wallet_outlined,
                    actionLabel: l10n.walletsAddWallet,
                    onAction: _openAddWallet,
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: WalletsHeader(
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onAddWallet: _openAddWallet,
                  ),
                ),
                if (summary != null)
                  SliverToBoxAdapter(
                    child: WalletsSummarySection(summary: summary),
                  ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        l10n.walletsSearchHint,
                        style: TextStyle(color: context.appColors.textMuted),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: WalletsGroupedCard(
                        treasuries: filtered,
                        onEdit: _openEditWallet,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
