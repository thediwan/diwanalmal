import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../extensions/context_l10n.dart';
import '../extensions/context_theme.dart';

/// Bottom navigation: home, transactions, wallets, settings (design spec).
class AppScaffoldShell extends StatelessWidget {
  const AppScaffoldShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int get _selectedIndex {
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/wallets')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/transactions');
      case 2:
        context.go('/wallets');
      case 3:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colors.navBarBackground,
        indicatorColor: primary.withValues(alpha: 0.12),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: primary),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: primary),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: primary),
            label: l10n.navWallets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: primary),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
