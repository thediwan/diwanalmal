# Monthly Financial Reports Module

## Overview

Production monthly report system with frozen snapshots, insights, surplus handling, PDF export, and historical comparison.

## Architecture

```
presentation/ → MonthlyReportProvider → MonthlyReportService
                                      → MonthlyReportRepositoryImpl
                                      → FinanceDao aggregations
```

Domain layer: entities, `InsightRuleEngine`, repository interface.

## Routes

| Route | Purpose |
|-------|---------|
| `/reports` | Historical list |
| `/reports/:year/:month` | Full report dashboard |
| `/reports/compare` | Two-month comparison |

## Report Lifecycle

1. **Generate** — aggregates income/expense/categories/budgets/goals/trends
2. **Draft** — surplus actions available
3. **Finalize** — carry forward or allocate to goal (transfer)
4. **PDF** — multi-page export via `pdf` + `share_plus`

## Automation

- `ReportSchedulerService` — WorkManager task on 1st of month
- App launch catch-up via `ensurePreviousMonthReport()`
- Auto carry-forward after 7-day grace (`autoFinalizeStaleDrafts`)

## Insights

Rule-based engine (`InsightRule`) with l10n keys stored in snapshot JSON.

## Last Updated

2026-06-20
