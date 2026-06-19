import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../extensions/context_l10n.dart';
import '../extensions/context_theme.dart';
import '../responsive/app_breakpoints.dart';
import '../responsive/responsive_layout.dart';

/// Adaptive shell: bottom nav on compact, navigation rail on medium+.
class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  static const _destinations = [
    _ShellDestination(
      branchIndex: 0,
      path: '/',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
    ),
    _ShellDestination(
      branchIndex: 1,
      path: '/transactions',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    _ShellDestination(
      branchIndex: 2,
      path: '/wallets',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    _ShellDestination(
      branchIndex: 3,
      path: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  int get _selectedIndex {
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/wallets')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onDestinationSelected(int index) {
    final destination = _destinations[index];
    navigationShell.goBranch(
      destination.branchIndex,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ResponsiveLayout(
      builder: (context, sizeClass) {
        final body = SafeArea(
          bottom: sizeClass == WindowSizeClass.compact ? false : true,
          child: navigationShell,
        );

        if (sizeClass == WindowSizeClass.compact) {
          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            body: body,
            bottomNavigationBar: _buildBottomNav(context),
          );
        }

        final extended = sizeClass != WindowSizeClass.medium;

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          body: Row(
            children: [
              _buildNavigationRail(context, extended: extended),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }

  NavigationBar _buildBottomNav(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final labels = [
      l10n.navHome,
      l10n.navTransactions,
      l10n.navWallets,
      l10n.navSettings,
    ];

    return NavigationBar(
      backgroundColor: colors.navBarBackground,
      indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.12),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: [
        for (var i = 0; i < _destinations.length; i++)
          NavigationDestination(
            icon: Icon(_destinations[i].icon),
            selectedIcon: Icon(
              _destinations[i].selectedIcon,
              color: AppColors.primaryContainer,
            ),
            label: labels[i],
          ),
      ],
    );
  }

  Widget _buildNavigationRail(BuildContext context, {required bool extended}) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final labels = [
      l10n.navHome,
      l10n.navTransactions,
      l10n.navWallets,
      l10n.navSettings,
    ];

    return NavigationRail(
      extended: extended,
      backgroundColor: colors.navBarBackground,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(
        color: AppColors.primaryContainer,
      ),
      unselectedIconTheme: IconThemeData(color: colors.textSecondary),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.primaryContainer,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: colors.textSecondary),
      destinations: [
        for (var i = 0; i < _destinations.length; i++)
          NavigationRailDestination(
            icon: Icon(_destinations[i].icon),
            selectedIcon: Icon(_destinations[i].selectedIcon),
            label: Text(labels[i]),
          ),
      ],
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.branchIndex,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final int branchIndex;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}
