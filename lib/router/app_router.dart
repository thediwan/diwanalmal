import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/extensions/context_l10n.dart';
import '../core/layouts/adaptive_app_shell.dart';
import '../features/auth/auth_splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/security_code_screen.dart';
import '../features/auth/setup_lock_screen.dart';
import '../features/auth/start_auth_screen.dart';
import '../features/auth/unlock_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/categories/category_form_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/appearance_screen.dart';
import '../features/profile/personal_info_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/security_screen.dart';
import '../features/transactions/transaction_edit_screen.dart';
import '../features/transactions/transaction_add_screen.dart';
import '../features/transactions/models/transaction_entry_type.dart';
import '../features/transactions/models/transaction_list_item.dart';
import '../features/transactions/transactions_list_screen.dart';
import '../database/daos/finance_dao.dart';
import '../core/constants/database_constants.dart';
import '../features/onboarding/select_base_currency_screen.dart';
import '../features/settings/currencies/currencies_screen.dart';
import '../features/settings/currencies/currency_form_screen.dart';
import '../features/goals/goal_edit_screen.dart';
import '../features/goals/goal_form_screen.dart';
import '../features/goals/goal_plan_screen.dart';
import '../features/goals/goal_savings_form_screen.dart';
import '../features/goals/models/goal_draft.dart';
import '../features/goals/models/goal_savings_mode.dart';
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
        redirect: (context, state) => '/settings',
      ),
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) => TransactionAddScreen(
          initialEntryType: _entryTypeFromQuery(state.uri.queryParameters['type']),
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => CategoriesScreen(
          initialType: _categoryTypeFromQuery(state.uri.queryParameters['type']),
        ),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => CategoryFormScreen(
              initialType: _categoryTypeFromQuery(state.uri.queryParameters['type']),
            ),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CategoryFormScreen(categoryId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final kind = state.extra is TransactionListKind
              ? state.extra as TransactionListKind
              : TransactionListKind.expense;
          return TransactionEditScreen(id: id, kind: kind);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveAppShell(
            navigationShell: navigationShell,
            location: state.uri.path,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/goals/add',
                builder: (context, state) {
                  final draft = state.extra is GoalDraft
                      ? state.extra as GoalDraft
                      : null;
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
                routes: [
                  GoRoute(
                    path: 'deposit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return GoalSavingsFormScreen(
                        goalId: id,
                        mode: GoalSavingsMode.deposit,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'withdraw',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return GoalSavingsFormScreen(
                        goalId: id,
                        mode: GoalSavingsMode.withdraw,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => TransactionsListScreen(
                  initialTab: _activityFeedTabFromQuery(
                    state.uri.queryParameters['tab'],
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TransactionsListScreen(
                        initialTab: _activityFeedTabFromQuery(
                          state.uri.queryParameters['tab'],
                        ),
                        selectedTransactionId: id,
                        selectedKind: _transactionListKindFromQuery(
                          state.uri.queryParameters['kind'],
                        ),
                      );
                    },
                  ),
                ],
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
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'personal-info',
                    builder: (context, state) => const PersonalInfoScreen(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (context, state) => const SecurityScreen(),
                  ),
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) => const AppearanceScreen(),
                  ),
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

TransactionListKind? _transactionListKindFromQuery(String? raw) {
  switch (raw) {
    case 'expense':
      return TransactionListKind.expense;
    case 'income':
      return TransactionListKind.income;
    case 'transfer':
      return TransactionListKind.transfer;
    case 'debtor':
      return TransactionListKind.debtor;
    case 'creditor':
      return TransactionListKind.creditor;
    case 'debt':
      return TransactionListKind.debtor;
    default:
      return null;
  }
}

ActivityFeedTab? _activityFeedTabFromQuery(String? raw) {
  switch (raw) {
    case 'expense':
      return ActivityFeedTab.expense;
    case 'income':
      return ActivityFeedTab.income;
    case 'transfer':
      return ActivityFeedTab.transfer;
    case 'debt':
      return ActivityFeedTab.debt;
    default:
      return null;
  }
}

TransactionEntryType? _entryTypeFromQuery(String? raw) {
  switch (raw) {
    case 'expense':
      return TransactionEntryType.expense;
    case 'income':
      return TransactionEntryType.income;
    case 'transfer':
      return TransactionEntryType.currencyTransfer;
    case 'debtor':
      return TransactionEntryType.debtor;
    case 'creditor':
      return TransactionEntryType.creditor;
    default:
      return null;
  }
}

String _categoryTypeFromQuery(String? raw) {
  if (raw == 'income') {
    return DatabaseConstants.categoryIncome;
  }
  return DatabaseConstants.categoryExpense;
}
