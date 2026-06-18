# Financial Goals Module

## Overview

Each financial goal is backed by a dedicated treasury wallet. Saved money lives in that wallet; progress is derived from its balance, not a manually edited number.

## Data Model (schema v11)

| Table | Field | Purpose |
|-------|-------|---------|
| `goals` | `wallet_id` | FK to the goal's savings wallet |
| `goals` | `saved_amount` | Cache synced from wallet balance after transfers |
| `goals` | `target_amount`, `target_date`, `icon`, … | Planning metadata |

No `goal_contributions` table. Deposits and withdrawals are ordinary rows in `transfers`.

## Business Rules

1. **Goal creation** (`GoalService.createFromDraft`): creates wallet + currency account, inserts goal with `wallet_id`. If initial saved amount > 0, requires a source wallet and records an opening transfer.
2. **Deposit** (`GoalService.deposit`): transfer from a regular wallet → goal wallet via dedicated form `/goals/:id/deposit`.
3. **Withdraw** (`GoalService.withdraw`): transfer from goal wallet → regular wallet via `/goals/:id/withdraw`.
4. **Progress**: `saved_amount / target_amount` (clamped 0–100%). `saved_amount` synced via `FinanceDao.syncGoalSavedAmount`.
5. **Monthly plan**: `GoalPlanningService.monthlyRequiredFor` vs net transfers this month.
6. **Delete**: blocked while goal wallet balance > 0; wallet is soft-deleted with the goal.
7. **Never** use income/expense for goal savings — only transfers.
8. **Goal wallets are hidden** from normal transaction wallet pickers (`treasury_filters.regularTreasuries`).
9. **Transactions list**: goal deposits/withdrawals are labeled distinctly (savings icon, green/red amount) — e.g. "Deposit to {goal}" with "From wallet {name}" in the subtitle.

## UI

| Screen | Behavior |
|--------|----------|
| Goal form | Optional opening savings + source wallet picker (regular wallets only) |
| Goal edit | Read-only saved amount, deposit/withdraw buttons, transfer history |
| Goal savings form | Dedicated deposit/withdraw screen (`GoalSavingsFormScreen`) |
| Wallets list | Goal wallets show a "Goal" badge (`Treasury.isGoalWallet`) |
| Transaction add/edit | Goal wallets excluded from pickers (existing goal transfer edits keep selected wallet visible) |
| Transactions list | Goal transfers detected via `getGoalWalletTitles`; shown as `goalDeposit` / `goalWithdraw` rows |

## Key Files

- `lib/services/goal_service.dart` — `deposit`, `withdraw`
- `lib/features/goals/goal_savings_form_screen.dart`
- `lib/core/helpers/treasury_filters.dart`
- `lib/database/daos/finance_dao.dart`
- `lib/services/transfer_service.dart`
- `lib/services/treasury_service.dart`

## Last Updated

2026-06-18 — Distinct goal deposit/withdraw labels in transactions list; dedicated savings form.
