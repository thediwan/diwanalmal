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

## Last Updated

2026-06-20 — Monthly Financial Report System implemented.
