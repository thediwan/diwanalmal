# Monthly Budgets Module

## Overview

Monthly spending limits per expense category. Used by the Monthly Financial Report for budget vs actual analysis.

## Routes

| Route | Screen |
|-------|--------|
| `/budgets` | List with month picker, progress bars, copy-from-previous |
| `/budgets/add?year=&month=` | Create budget |
| `/budgets/:id/edit` | Edit amount |

## Data

Table: `budgets` — `categoryId`, `month`, `year`, `amount`, `currencyId`

## Services

- `BudgetService` — CRUD + validation (expense categories only, one per category/month)
- `BudgetProvider` — UI state

## Entry Points

- Profile → Financial → Budgets
- Monthly report → Manage budgets (when empty)

## Last Updated

2026-06-20
