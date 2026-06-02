import 'package:go_router/go_router.dart';

import '../core/widgets/main_shell.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/onboarding/select_base_currency_screen.dart';
import '../features/settings/currencies/currencies_screen.dart';
import '../features/settings/currencies/currency_form_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/wallets/wallet_form_screen.dart';
import '../features/wallets/wallets_screen.dart';
import '../providers/settings_provider.dart';

/// Application routing with onboarding redirect.
class AppRouter {
  AppRouter(this._settingsProvider);

  final SettingsProvider _settingsProvider;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _settingsProvider,
    redirect: (context, state) {
      final isSetupComplete = _settingsProvider.isSetupComplete;
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!isSetupComplete && !isOnboarding) {
        return '/onboarding';
      }

      if (isSetupComplete && isOnboarding) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const SelectBaseCurrencyScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallets',
                builder: (context, state) => const WalletsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const WalletFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return WalletFormScreen(walletId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'currencies',
                    builder: (context, state) => const CurrenciesScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const CurrencyFormScreen(),
                      ),
                      GoRoute(
                        path: ':id/edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return CurrencyFormScreen(currencyId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
