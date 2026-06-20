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

## Last Updated

2026-06-20 — Transactions list: full title display; notes preview limited to 2 words in list tile only.
2026-06-20 — Transaction add screen: income category grid (income-only), expense overflow category picker (7+More), notes keyboard scroll fix.
2026-06-20 — Transfer exchange rate unified with currency form (`ExchangeRateDisplay`); manual edits update stored rates.
2026-06-20 — Transaction dates use numeric `yyyy/MM/dd` format via `AppDateFormatter`.
2026-06-20 — Monthly Financial Report System implemented.
