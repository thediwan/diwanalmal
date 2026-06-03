# Bayt Al-Mal — Project Progress

## Overview

Offline-first Flutter personal finance app (Hive, Provider, GoRouter). Arabic is the default locale; English strings are available via `lib/l10n/`.

## Structure

```
lib/
├── core/          # theme, constants, extensions (context.l10n), widgets
├── features/      # auth, onboarding, wallets, dashboard, settings
├── l10n/          # app_ar.arb, app_en.arb, generated app_localizations.dart
├── models/        # Hive models
├── providers/     # settings, currency, wallet
├── router/        # GoRouter + auth redirects
└── services/      # auth, hive, biometric, currency, wallet
```

## Completed (auth & foundation)

- Registration → PIN/biometric setup → security code screen → base currency onboarding
- Session lock (PIN/biometric) with lifecycle-aware locking
- Forgot password via offline security code (`/auth/reset-password`)
- Localization for all auth screens (`context.l10n`)
- Router redirects and navigation fixes (no `notifyListeners` before security-code navigation)

## In progress / next

- Migrate remaining features (onboarding, wallets, settings, dashboard) to `context.l10n`
- Transactions and reporting (phase 2)

## Environment

- Flutter SDK ^3.5.4
- Run: `flutter pub get` → `flutter gen-l10n` → `flutter run`
- Default locale: `ar` (see `lib/main.dart`)

## Critical behaviors (do not regress)

1. Security code is created in `AuthService.completeSecuritySetup()`, not at register.
2. After PIN save, navigate with `context.go('/auth/security-code', extra: code)` only — do not call `notifyListeners()` before that navigation.
3. `main.dart` uses `context.select` for `themeMode` only to avoid full-app rebuilds on auth state changes.
