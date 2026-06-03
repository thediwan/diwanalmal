# Bayt Al-Mal — Project Progress

## Overview

Offline-first Flutter personal finance app (Lazarus SQLite via Drift + Hive for auth/settings, Provider, GoRouter). Arabic is the default locale; English strings are available via `lib/l10n/`.

## Structure

```
lib/
├── core/          # theme, constants, extensions (context.l10n), widgets
├── features/      # auth, onboarding, wallets, dashboard, settings
├── l10n/          # app_ar.arb, app_en.arb, generated app_localizations.dart
├── database/      # Drift schema, DAOs, seed (lazarus.db)
├── models/        # app models (Hive + UI)
├── providers/     # settings, currency, wallet
├── router/        # GoRouter + auth redirects
└── services/      # auth, hive, lazarus, currency, wallet, dashboard
```

## Completed (auth & foundation)

- Registration → PIN/biometric setup → security code screen → base currency onboarding
- Session lock (PIN/biometric) with lifecycle-aware locking
- Forgot password via offline security code (`/auth/reset-password`)
- Localization for all auth screens (`context.l10n`)
- Router redirects and navigation fixes (no `notifyListeners` before security-code navigation)

## Lazarus database (SQLite)

- Full schema per product spec — see `docs/database-lazarus.md`
- Seed data on first launch (currencies, wallets, transactions, debts, goals)
- Wallet balances computed from transactions/transfers (not stored)
- Hive one-time migration for existing currencies/wallets

## In progress / next

- Migrate remaining features (onboarding, wallets, settings) to `context.l10n`
- Transactions CRUD UI wired to `transactions` table
- Move auth from Hive to `auth_local` / `security_settings`

## Dashboard (UI + Lazarus data)

- Matches design mockup: header, balance, currency row, monthly summary, goals, chart, transactions, 4-tab bottom nav
- **From Lazarus:** monthly income/expense, debts, goals, recent transactions, expense chart, wallet balances
- Routes: `/profile` (placeholder), `/transactions/add` (placeholder), FAB on dashboard
- **Alignment plan:** `docs/dashboard-design-alignment-plan.md` + seed spec `docs/seeds/dashboard-mockup.json`

## Environment

- Flutter SDK ^3.5.4
- Run: `flutter pub get` → `dart run build_runner build` → `flutter gen-l10n` → `flutter run`
- Default locale: `ar` (see `lib/main.dart`)

## Critical behaviors (do not regress)

1. Security code is created in `AuthService.completeSecuritySetup()`, not at register.
2. After PIN save, navigate with `context.go('/auth/security-code', extra: code)` only — do not call `notifyListeners()` before that navigation.
3. `main.dart` uses `context.select` for `themeMode` only to avoid full-app rebuilds on auth state changes.
