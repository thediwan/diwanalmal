import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extensions/context_l10n.dart';
import '../core/widgets/app_scaffold_shell.dart';
import '../features/auth/auth_splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/security_code_screen.dart';
import '../features/auth/setup_lock_screen.dart';
import '../features/auth/start_auth_screen.dart';
import '../features/auth/unlock_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/profile_placeholder_screen.dart';
import '../features/transactions/transaction_add_placeholder_screen.dart';
import '../features/transactions/transactions_list_placeholder_screen.dart';
import '../features/onboarding/select_base_currency_screen.dart';
import '../features/settings/currencies/currencies_screen.dart';
import '../features/settings/currencies/currency_form_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/goals/goal_edit_screen.dart';
import '../features/goals/goal_form_screen.dart';
import '../features/goals/goal_plan_screen.dart';
import '../features/goals/models/goal_draft.dart';
import '../features/wallets/wallet_form_screen.dart';
import '../features/wallets/wallets_screen.dart';
import '../providers/settings_provider.dart';

/// Application routing with auth lock and onboarding redirects.
class AppRouter {
  AppRouter(this._settingsProvider);

  final SettingsProvider _settingsProvider;

  late final GoRouter router = GoRouter(
    initialLocation: '/auth/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: _settingsProvider,
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.error?.toString() ?? context.l10n.routeError,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/auth/splash',
        builder: (context, state) => const AuthSplashScreen(),
      ),
      GoRoute(
        path: '/auth/start',
        builder: (context, state) => const StartAuthScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/security-code',
        builder: (context, state) {
          final extra = state.extra;
          final code = extra is String && extra.isNotEmpty
              ? extra
              : (_settingsProvider.displaySecurityCode.isNotEmpty
                  ? _settingsProvider.displaySecurityCode
                  : _settingsProvider.securityCode);
          return SecurityCodeScreen(securityCode: code);
        },
      ),
      GoRoute(
        path: '/auth/setup-lock',
        builder: (context, state) => const SetupLockScreen(),
      ),
      GoRoute(
        path: '/auth/unlock',
        builder: (context, state) => const UnlockScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const SelectBaseCurrencyScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePlaceholderScreen(),
      ),
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) => const TransactionAddPlaceholderScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffoldShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/goals/add',
            builder: (context, state) {
              final draft = state.extra is GoalDraft ? state.extra as GoalDraft : null;
              return GoalFormScreen(initialDraft: draft);
            },
          ),
          GoRoute(
            path: '/goals/plan',
            builder: (context, state) {
              final draft = state.extra;
              if (draft is! GoalDraft) {
                return const GoalFormScreen();
              }
              return GoalPlanScreen(draft: draft);
            },
          ),
          GoRoute(
            path: '/goals/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return GoalEditScreen(goalId: id);
            },
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) =>
                const TransactionsListPlaceholderScreen(),
          ),
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
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final settings = _settingsProvider;

    if (!settings.hasAccount) {
      if (!location.startsWith('/auth')) return '/auth/start';
      return null;
    }

    if (!settings.isSecuritySetupComplete) {
      return location == '/auth/setup-lock' ? null : '/auth/setup-lock';
    }

    if (settings.needsSecurityCodeScreen) {
      return location == '/auth/security-code' ? null : '/auth/security-code';
    }

    if (settings.requiresUnlock) {
      const allowedWhileLocked = {
        '/auth/unlock',
        '/auth/login',
        '/auth/reset-password',
      };
      if (allowedWhileLocked.contains(location)) return null;
      return '/auth/unlock';
    }

    if (!settings.isSetupComplete) {
      return location == '/onboarding' ? null : '/onboarding';
    }

    if (location == '/onboarding' || location.startsWith('/auth')) {
      return '/';
    }

    return null;
  }
}
