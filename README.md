<p align="center">
  <img src="assets/images/logo-light.png" alt="Diwan Al-Mal logo" width="180" />
</p>

<h1 align="center">Diwan Al-Mal</h1>

<p align="center">
  <strong>ديوان المال — A privacy-first personal finance manager built with Flutter</strong>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter&logoColor=white" alt="Flutter 3.5+" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white" alt="Dart 3.5+" /></a>
  <a href="#platforms"><img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Desktop%20%7C%20Web-blue" alt="Supported platforms" /></a>
  <a href="#license"><img src="https://img.shields.io/badge/License-GPL--3.0--or--later-blue" alt="GPL-3.0-or-later" /></a>
  <a href="docs/f-droid-publishing-plan.md"><img src="https://img.shields.io/badge/F--Droid-planned-00CF35?logo=f-droid&logoColor=white" alt="F-Droid planned" /></a>
</p>

<p align="center">
  Offline-first · Arabic-first · Multi-currency · Open source
</p>

---

## About

**Diwan Al-Mal** (*Dewan Al-Mal*, Arabic for “the treasury”) is a cross-platform personal finance application that keeps your financial data on your device. There is no cloud dependency in Phase 1: wallets, transactions, goals, budgets, and reports all live locally in a SQLite database you control.

The app is designed for **Arabic-speaking users first** — RTL layout, Arabic typography, and full English localization — while following Flutter best practices and a modular architecture that can grow toward multi-user support without a rewrite.

| | |
|---|---|
| **Display name** | ديوان المال (Diwan Al-Mal) |
| **Package name** | `diwanalmal` |
| **Application ID** | `org.thediwan.diwanalmal` |
| **Version** | 1.0.0+1 |
| **Repository** | [github.com/thediwan/diwanalmal](https://github.com/thediwan/diwanalmal) |
| **License** | [GPL-3.0-or-later](LICENSE) |

---

## Why Diwan Al-Mal?

- **Your data stays local** — Financial records are stored in `lazarus.db` on-device. No account server required to track income and expenses.
- **Built for Arabic UX** — RTL-first design, dedicated heading and body fonts, and bilingual UI strings via `flutter gen-l10n`.
- **Multi-currency by design** — Manage wallets in different currencies with frozen exchange rates at transaction time.
- **Computed balances** — Wallet balances are derived from transactions and transfers, not stored as mutable totals.
- **Real features, not a demo** — Auth, dashboards, reports, budgets, goals, backup, and PDF export are implemented as production modules.

---

## Features

### Available now

| Area | Capabilities |
|------|--------------|
| **Security** | Local registration & login, 4-digit PIN, biometric unlock (fingerprint / Face ID), recovery code, session lock |
| **Dashboard** | Total balance, multi-currency overview, monthly summary, savings goals, expense charts, recent transactions |
| **Wallets** | Create, edit, delete, search; opening balances; multi-currency accounts per wallet |
| **Transactions** | Income, expense, wallet transfers, debts (payable / receivable), filters & search |
| **Goals** | Goal creation → suggested savings plan → accept or customize; deposits & withdrawals |
| **Budgets** | Monthly budget planning and tracking |
| **Categories** | Two fixed system categories + user-managed custom categories |
| **Currencies** | Full CRUD with a configurable base currency |
| **Reports** | Monthly financial reports, insights, month-over-month comparison, PDF export |
| **Backup** | Scheduled local backups (`.dmbackup` archive), manual export & import |
| **Settings** | Light / dark / system theme, color palettes, currency management, number formatting |
| **Localization** | Arabic (default, RTL) and English |

### In progress or planned

| Module | Status |
|--------|--------|
| Debt payment / collection flows | Planned — `debt_payments` |
| Full auth unification (Hive → Lazarus SQL) | Phase 4 |
| Cloud sync & multi-user | Future phase |
| Expanded test coverage | Ongoing |

See [`docs/project-progress.md`](docs/project-progress.md) for the latest roadmap and priorities.

---

## Platforms

Diwan Al-Mal targets all Flutter-supported platforms:

**Android** · **iOS** · **Windows** · **macOS** · **Linux** · **Web**

Biometric authentication and background backup scheduling are most mature on **Android** and **iOS**. Desktop builds are supported; see [Windows build notes](#windows-build-notes) below.

---

## Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter (Material 3) |
| State management | [Provider](https://pub.dev/packages/provider) |
| Routing | [GoRouter](https://pub.dev/packages/go_router) |
| Financial data | SQLite + [Drift](https://drift.simonbinder.eu/) → `lazarus.db` |
| Session & settings | [Hive](https://pub.dev/packages/hive) (`AppSettings`) |
| Biometrics | [`local_auth`](https://pub.dev/packages/local_auth) |
| Charts | [`fl_chart`](https://pub.dev/packages/fl_chart) |
| PDF export | [`pdf`](https://pub.dev/packages/pdf) + [`printing`](https://pub.dev/packages/printing) |
| Background tasks | [`workmanager`](https://pub.dev/packages/workmanager) |
| Headings font | **Qomra** — `assets/fonts/Qomra.ttf` |
| Body font | **Alyamama** — `assets/fonts/Alyamama.ttf` |
| Localization | `flutter gen-l10n` — `lib/l10n/app_ar.arb`, `app_en.arb` |

---

## Architecture

Diwan Al-Mal follows a feature-first folder layout with shared core utilities, services, and a Drift-powered data layer.

```
lib/
├── core/              # Theme, colors, extensions, shared widgets, charts
├── features/
│   ├── auth/          # Registration, login, PIN, biometrics, recovery
│   ├── onboarding/    # Base currency selection
│   ├── dashboard/     # Home dashboard
│   ├── wallets/         # Wallet (treasury) management
│   ├── transactions/    # Transactions, transfers, debts
│   ├── goals/           # Financial goals & savings plans
│   ├── budgets/         # Monthly budgets
│   ├── categories/      # Category management
│   ├── reports/         # Monthly reports & PDF export
│   ├── settings/        # Settings, currencies, backup
│   └── profile/         # Profile, appearance, security
├── database/          # Drift tables, DAOs, seeds
├── l10n/              # ARB localization files
├── models/
├── providers/
├── router/            # GoRouter + auth redirect guards
└── services/          # Auth, backup, reports, balances, etc.

docs/                  # Module & architecture documentation
assets/
├── fonts/             # Qomra, Alyamama
├── images/            # App logos & backgrounds
└── icon/              # Launcher icons
```

### Design principles

1. **Offline-first** — Financial data lives in `lazarus.db`; Phase 1 has no network dependency.
2. **Single active user** — `getActiveUserId()` returns the first active user; architecture leaves room for multi-user later.
3. **Computed wallet balances** — Balances are calculated from transactions and transfers, never stored on the wallet row.
4. **Frozen exchange rates** — `exchange_rate` and `base_amount` are persisted at transaction entry time.
5. **No hardcoded UI strings** — Use `context.l10n` for all user-facing text.
6. **RTL is mandatory** — Every new screen must be verified in Arabic layout.

### Balance formula

```
wallet_balance = opening_balance + income − expense + transfers_in − transfers_out
```

Database schema details: [`docs/database-lazarus.md`](docs/database-lazarus.md)

---

## Getting started

### Prerequisites

- Flutter SDK **3.44.1** (pinned in [`.flutter-version`](.flutter-version) and [`.flutter/`](.flutter) submodule)
- Dart **3.12.1** (bundled with pinned Flutter)
- For **Windows** desktop builds: Visual Studio with C++ desktop development workload ([Flutter Windows setup](https://docs.flutter.dev/platform-integration/windows/setup))
- For **Android** release builds: Android SDK ([Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup))

### Clone & run

```bash
git clone --recurse-submodules https://github.com/thediwan/diwanalmal.git
cd diwanalmal

# If you already cloned without submodules:
git submodule update --init --recursive

.flutter/bin/flutter pub get --enforce-lockfile
.flutter/bin/dart run build_runner build --delete-conflicting-outputs
.flutter/bin/flutter gen-l10n
.flutter/bin/flutter run
```

Alternatively, use a system Flutter matching `.flutter-version` (3.44.1):

```bash
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

Pick a target device when prompted, or specify one explicitly:

```bash
flutter run -d windows
flutter run -d chrome
flutter run -d <device-id>
```

### Verify the project

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Regenerate launcher icons

After updating `assets/icon/app_icon.png`:

```bash
dart run flutter_launcher_icons
flutter clean
flutter build windows   # or your target platform
```

> On Windows, the icon is embedded in the `.exe` from `windows/runner/resources/app_icon.ico`. Hot reload does **not** update it — a full rebuild is required.

### Reset seed / demo data

Demo seeds are **disabled by default** (`SeedConstants.enabled = false`).

To start fresh:

1. Uninstall the app from the device or emulator, **or**
2. Delete `lazarus.db` from the app's data directory

### After native changes

When modifying Android, iOS, or Windows native code or plugins, stop the app and perform a **full rebuild**. Hot reload is not sufficient.

---

## Windows build notes

If the build fails with MSVC error `STL1011` (coroutine deprecation) in plugins such as `local_auth_windows`, the project includes a workaround in `windows/CMakeLists.txt`:

```cmake
add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)
```

---

## Authentication flows

**New user**

```
/auth/start → /auth/register → /auth/setup-lock → /auth/security-code → /onboarding → /
```

**Returning user (locked session)**

```
/auth/splash → /auth/start or /auth/unlock → app
```

**Forgot password**

```
/auth/login → /auth/reset-password → /auth/login
```

### Redirect priority

1. No account → `/auth/start`
2. No PIN configured → `/auth/setup-lock`
3. Security code required → `/auth/security-code`
4. Session locked → `/auth/unlock`
5. Onboarding incomplete → `/onboarding`
6. Authenticated auth/onboarding routes → `/`

Full auth module documentation: [`docs/modules/auth.md`](docs/modules/auth.md)

---

## Main routes

```
/auth/splash | /auth/start | /auth/register | /auth/login
/auth/setup-lock | /auth/security-code | /auth/unlock | /auth/reset-password
/onboarding
/                          ← Dashboard (shell)
/transactions | /transactions/add | /transactions/:id
/wallets | /wallets/add | /wallets/:id/edit
/goals/add | /goals/plan | /goals/:id
/budgets | /budgets/add | /budgets/:id/edit
/categories | /categories/add | /categories/:id/edit
/reports | /reports/:year/:month | /reports/compare
/settings | /settings/currencies
/profile
```

---

## Documentation

| Topic | Document |
|-------|----------|
| Project progress & roadmap | [`docs/project-progress.md`](docs/project-progress.md) |
| Database schema (Lazarus) | [`docs/database-lazarus.md`](docs/database-lazarus.md) |
| Responsive layout | [`docs/responsive-architecture.md`](docs/responsive-architecture.md) |
| Authentication | [`docs/modules/auth.md`](docs/modules/auth.md) |
| Backup module | [`docs/modules/backup.md`](docs/modules/backup.md) |
| Monthly reports | [`docs/modules/reports.md`](docs/modules/reports.md) |
| Budgets | [`docs/modules/budgets.md`](docs/modules/budgets.md) |
| Goals | [`docs/modules/goals.md`](docs/modules/goals.md) |
| Number formatting | [`docs/modules/number-formatting.md`](docs/modules/number-formatting.md) |
| Theming & color palettes | [`docs/modules/color-palettes-and-theming.md`](docs/modules/color-palettes-and-theming.md) |
| Dashboard design spec | [`docs/dashboard-design-alignment-plan.md`](docs/dashboard-design-alignment-plan.md) |
| F-Droid publishing plan | [`docs/f-droid-publishing-plan.md`](docs/f-droid-publishing-plan.md) |
| F-Droid local build runbook | [`docs/fdroid-server-runbook.md`](docs/fdroid-server-runbook.md) |
| F-Droid release runbook | [`docs/fdroid-release-runbook.md`](docs/fdroid-release-runbook.md) |
| Third-party licenses | [`docs/third-party-licenses.md`](docs/third-party-licenses.md) |

---

## Contributing

Contributions are welcome. Whether you fix a bug, improve documentation, add tests, or propose a feature, please:

1. **Fork** the repository and create a branch from `main`.
2. **Follow existing conventions** — feature-first structure, Provider for state, GoRouter for navigation, Drift for persistence.
3. **Localize all user-facing text** — add keys to `app_ar.arb` and `app_en.arb`; never hardcode UI strings.
4. **Test RTL** — verify layouts in Arabic before opening a pull request.
5. **Run analysis** before submitting:

   ```bash
   flutter analyze
   flutter test
   ```

6. Open a **pull request** with a clear description of the change and how you tested it.

For larger changes, open an issue first to discuss scope and approach.

### Developer guidelines

- **Security code** is generated only in `AuthService.completeSecuritySetup()`.
- **After saving a PIN**, navigate with `context.go('/auth/security-code', extra: code)` — do not call `notifyListeners()` before navigation.
- **Session lock** triggers on `paused` / `detached`, not `inactive` (avoids breaking the biometric prompt).
- **Never store wallet balance** in the `wallets` table — use `WalletBalanceService`.
- **Android biometrics** require `MainActivity` to extend `FlutterFragmentActivity`.

---

## Roadmap (summary)

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | Foundation, auth, dashboard, wallets | ~85% |
| 2 | Transactions, transfers, debts | Complete |
| 3 | Goals, debt payments, budgets | Partial |
| 4 | Unify Hive ↔ Lazarus for auth | Planned |
| 5 | Profile, notifications, UX polish | Planned |
| 6 | Reports & export | In progress |
| 7 | Testing & quality | Planned |
| 8 | Backup, sync, multi-user | Partial / planned |

Detailed milestones: [`docs/project-progress.md`](docs/project-progress.md)

---

## License

Diwan Al-Mal is free software licensed under the **GNU General Public License v3.0 or later** (GPL-3.0-or-later).

- Full license text: [LICENSE](LICENSE)
- SPDX identifier: `GPL-3.0-or-later`

You may use, modify, and distribute this software under the terms of the GPL. Derivative works must also be licensed under the GPL and provide corresponding source code. See the [GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html) for common questions.

Copyright © 2026 [The Diwan](https://github.com/thediwan).

---

## F-Droid

We are preparing Diwan Al-Mal for inclusion in [F-Droid](https://f-droid.org/) — the community-maintained repository of free and open source Android apps.

The full checklist, blockers, metadata layout, build recipe outline, and timeline are documented in [`docs/f-droid-publishing-plan.md`](docs/f-droid-publishing-plan.md).

**Maintainer runbooks:**

- Local fdroidserver validation: [`docs/fdroid-server-runbook.md`](docs/fdroid-server-runbook.md)
- Submission and version bumps: [`docs/fdroid-release-runbook.md`](docs/fdroid-release-runbook.md)
- Draft fdroiddata recipe: [`fdroid/org.thediwan.diwanalmal.yml`](fdroid/org.thediwan.diwanalmal.yml)

---

## Acknowledgments

Built with [Flutter](https://flutter.dev) and maintained by [The Diwan](https://github.com/thediwan).

---

<p align="center">
  <sub>Last updated: June 2026 · See <a href="docs/project-progress.md">docs/project-progress.md</a> for the latest project status.</sub>
</p>
