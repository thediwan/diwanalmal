# Dewan Al-Mal — Project Context

## Overview

Offline-first personal finance app (Arabic-first, RTL). Package: `baytalmal`.

## Architecture

- **State:** Provider
- **Routing:** GoRouter
- **Database:** Drift/SQLite (`lazarus.db`, schema v14)
- **Pattern:** UI → Service → FinanceDao → SQLite

## Monthly Financial Reports (v14)

- **Feature root:** `lib/features/reports/` (domain / data / presentation)
- **Budgets:** `lib/features/budgets/`
- **Tables:** `monthly_reports` (frozen snapshots), existing `budgets`
- **Services:** `MonthlyReportService`, `MonthlyReportPdfService`, `ReportSchedulerService`, `BudgetService`
- **Providers:** `MonthlyReportProvider`, `BudgetProvider`
- **Routes:** `/reports`, `/reports/:year/:month`, `/reports/compare`, `/budgets`

Reports store immutable KPI snapshots + JSON breakdowns. Surplus can be carried forward or allocated to goals via transfers.

## Date Display (Transactions)

- **Helper:** `lib/core/helpers/app_date_formatter.dart` — numeric `yyyy/MM/dd` (e.g. `2026/06/20`)
- Used in transaction list day headers, due dates, add/edit forms, and list filters

## Exchange Rate Display (Transfers)

- **Helper:** `lib/core/helpers/exchange_rate_display.dart`
- Unified rule app-wide: **`1 {base} = X {currency}`** (same as currency add/edit form)
- Transfer UI shows/edits the rated currency's display rate vs base (source if non-base, else target)
- Cross-currency conversion derived internally from both currencies' `rateToBase`
- Manual rate edits during transfer persist to the `currencies` table via `CurrencyProvider.updateCurrency`

## Persistence & Startup (v14+)

- **DB open:** `DatabaseOpenGuard` (`lib/core/helpers/database_open_guard.dart`) — sidecar backup before open, idempotent v14 repair, restore-on-failure (never wipes user data).
- **Migrations:** Idempotent v12/v14 table creation in `LazarusDatabase`; `ensureLegacySchemaRepairs()` includes `monthly_reports`.
- **Workmanager:** Single init via `BackgroundWorkmanagerRegistry.ensureInitialized()` in `main.dart`.
- **Startup:** Backup/report scheduling and monthly report catch-up are non-fatal (logged, do not block launch).

## Debt Ledger Balance Impact

- **Wallet balance:** `FinanceDao.transactionWalletBalanceDelta` — `debtor` (−), `creditor` (+), settlements via `income`/`expense`.
- **Monthly totals:** `sumMonthlyIncomeBase` includes creditor origination; `sumMonthlyExpenseBase` includes debtor origination.
- **Outstanding:** `sumOutstandingDebtsBase` tracks unpaid receivable/payable amounts on `debts` table.

## Last Updated

2026-06-20 — Debtor/creditor ledger entries now affect wallet balances, monthly totals, and settlement flow consistently.
2026-06-20 — Transaction add screen: overflow category picker includes "Manage categories" action below hidden items.
2026-06-20 — Transactions list: full title display; notes preview limited to 2 words in list tile only.
2026-06-20 — Transaction add screen: income category grid (income-only), expense overflow category picker (7+More), notes keyboard scroll fix.
2026-06-20 — Transfer exchange rate unified with currency form (`ExchangeRateDisplay`); manual edits update stored rates.
2026-06-20 — Transaction dates use numeric `yyyy/MM/dd` format via `AppDateFormatter`.
2026-06-20 — Monthly Financial Report System implemented.
