# Lazarus Database (Offline SQLite)

## Overview

Local financial data is stored in **`lazarus.db`** (SQLite via [Drift](https://drift.simonbinder.eu/) + `sqlite3` 3.x native hooks). This matches the offline-first “Lazarus” pattern: single source of truth on device, ready for sync later.

**Note:** `sqlite3_flutter_libs` is not used (deprecated). Android loads SQLite via `package:sqlite3` build hooks.

**File:** `lib/database/lazarus_database.dart`

## Tables (per product spec)

**Schema version:** 12

| Table | Purpose |
|-------|---------|
| `app_users` | Users (UUID, soft delete) |
| `auth_local` | Local username / password hash |
| `security_settings` | PIN hash, biometric flag (no biometric data) |
| `user_settings` | Base currency, language, theme |
| `currencies` | Codes, `rate_to_base`, `is_base` |
| `wallets` | Treasury (خزينة) — container name, icon, subtitle |
| `wallet_currency_accounts` | Opening balance per currency inside a treasury — **current balance is computed** |
| `categories` | income / expense |
| `contacts` | Reusable people for debts and transaction splits |
| `transactions` | amount, currency, `exchange_rate`, `base_amount`, optional `parent_transaction_id` |
| `transfers` | Wallet-to-wallet (not income/expense) |
| `debts` | owed_to_me / i_owe, optional `contact_id` |
| `transaction_splits` | Split header for shared income/expense |
| `transaction_split_participants` | Per-person share lines linked to debts |
| `debt_payments` | Partial repayments |
| `budgets` | Monthly category budgets |
| `goals` | Financial goals |
| `attachments` | Local file paths |

All main entities include `created_at`, `updated_at`, and `deleted_at` where specified.

## Balance rules

```
wallet_balance =
  opening_balance
  + income transactions
  - expense transactions
  + transfers in
  - transfers out
```

Implemented in `FinanceDao.computeWalletBalance()`.

## Transaction split sharing (v12)

When recording **income** or **expense** with sharing enabled:

- The **full amount** hits the wallet (expense − / income +).
- Each participant's share creates a linked **debt** ledger entry (`debtor` for expense, `creditor` for income).
- Split modes: equal, percent, fixed amount per person.
- Contacts are stored in `contacts` and reused across debts and splits.
- Child debt transactions reference the parent via `transactions.parent_transaction_id`.

Services: `ContactService`, `TransactionSplitService`, `SplitCalculator`.

## Test / seed data

On first launch with **no user**, `DatabaseSeedService` inserts:

- USD (base), TRY, SYP, EUR
- Wallets, categories, sample transactions
- Debt (Ahmed) + partial payment
- Goal “شراء سيارة”

**Demo login (seed only):** `demo` / `demo123` — PIN `1234` in DB (auth UI still uses Hive until migrated).

## Hive migration

Existing Hive currencies/wallets are imported once into Lazarus when no SQL user exists (`LazarusDatabaseService._migrateHiveIfNeeded`).

Auth/session flags remain in Hive `AppSettings` for now.

## Dashboard data source

| UI section | Source |
|------------|--------|
| Total balance | `WalletBalanceService` → transactions |
| My currencies | Wallet aggregates |
| Monthly income/expense | `transactions.base_amount` (current month) |
| Debts | `debts` − `debt_payments` |
| Goals | `goals` table |
| Recent transactions | `transactions` |
| Chart | Daily expense totals (last 30 days) |

## Regenerate code

```bash
dart run build_runner build
```
