# Dashboard Design Alignment Plan (Client Mockup)

This document maps the **client dashboard image** to the BaytAlmal implementation: UI specs, Lazarus data model, seeding, validation, and constraints.

**Reference image:** `assets/.../dashboard_1-*.png` (RTL Arabic, white background, primary blue `#1A56BE`).

**Preferred seed tool:** `DatabaseSeedService` in Dart (not Sider/SQLite browser) — runs automatically on first launch via `LazarusDatabaseService.initialize()`.

---

## 1. Visual & Compositional Specification

### Global

| Property | Value |
|----------|--------|
| Direction | RTL (`MaterialApp` locale `ar`) |
| Background | `#FFFFFF` |
| Primary blue | `#1A56BE` (`AppColors.dashboardPrimary`) |
| Muted blue (currency code) | `#5B8FD9` (`dashboardPrimaryMuted`) |
| Label grey | `#6B7280` |
| Caption grey | `#9CA3AF` |
| Divider | `#E5E7EB`, 1px |
| Section vertical padding | 18–24dp between blocks |
| Horizontal padding | 16dp (currency row: 4–8dp) |
| Fonts | Almarai (headings), Cairo (body) via `google_fonts` |

### A. Header

| Element | Position (visual) | Typography / color | Widget |
|---------|-------------------|----------------------|--------|
| Logo AMANAH | Left | 36×36, rounded 8px | `DashboardHeader` → `Image.asset(logo_amanah.png)` |
| Title «ديوان المال» | Center | 20sp, w800, `#1A56BE` | `AppConstants.appName` |
| Bell | Right | 40×40 circle, icon `#1A56BE` | `CupertinoIcons.bell` |
| Profile | Right of bell | 40×40, fill `#1A56BE` @ 12% alpha | `CupertinoIcons.person_crop_circle` → `/profile` |

**Gap vs mockup:** None if header row order is `[bell, profile, Expanded(title), logo]` in RTL.

### B. Total Balance

| Element | Spec |
|---------|------|
| Label | Centered, «الرصيد الإجمالي (USD)», 14sp, `#6B7280` |
| Amount row | LTR inline: `USD ` 22sp muted blue + `1,250.00` 36sp w800 `#1A56BE` |
| Data | `WalletProvider.totalBalanceInBase` |

**Widget:** `DashboardTotalBalance`.

### C. Multi-Currency Row (non-base only)

Three equal columns with vertical dividers. Order (RTL visual right → left): **TRY → SYP → EUR**.

| Column | Label | Main amount | Sub line |
|--------|-------|-------------|----------|
| TRY | الليرة التركية | `TRY 40,320.00` black w800 | `≈ USD 1,250` grey 11sp |
| SYP | الليرة السورية | `SYP 18,750,000` | `≈ USD 1,250` |
| EUR | اليورو | `EUR 1,150.00` | `≈ USD 1,250` |

**Data:** `buildDashboardCurrencyBalances()` — filter `!isBase`, sort `TRY, SYP, EUR`.

**Widget:** `DashboardCurrencyBalancesRow`.

### D. Monthly Summary (3 columns)

RTL order: **Income (right) | Expense (center) | Debts (left)**.

| Column | Title | Amount color | Secondary |
|--------|-------|--------------|-----------|
| Income | دخل الشهر | `#16A34A` | `+12% ↑` green 11sp |
| Expense | مصروف الشهر | `#DC2626` | `-5% ↓` red 11sp |
| Debts | الديون | `#EA580C` | «علي للآخرين» orange 11sp |

Amounts: LTR `USD 1,500` / `USD 250` / `USD 50`.

**Data:**

- Income/expense: `FinanceDao.sumTransactionsBaseAmount` (current month, `base_amount`).
- Debts: `sumOutstandingDebtsBase(type: i_owe)` → outstanding = amount − payments.
- **Gap:** `+12%` / `-5%` are **hardcoded** in UI today; not stored in DB (see §5).

**Widget:** `DashboardMonthlySummary`.

### E. Financial Goals

| Element | Spec |
|---------|------|
| Header | Title right «الأهداف المالية» w700; link left «إضافة هدف» `#1A56BE` 13sp |
| Row | Icon right (car, 28px blue) + title w700 + `%` left blue |
| Progress | 10px height, grey `#E5E7EB`, fill `#1A56BE`, **RTL fill** (24% from right) |

**Data:** `goals` → `saved_amount / target_amount` → 24% for car goal (3600 / 15000).

**Widget:** `DashboardGoalsSection`.

### F. Expense Analysis

| Element | Spec |
|---------|------|
| Title block | Right: «تحليل المصروفات» + «آخر 30 يوم» grey |
| Toggle | Left pill 140px: selected «يومي» white + shadow; «أسبوعي» grey |
| Chart | 180px height, spline `#1A56BE`, gradient fill, hollow dots |
| X-axis | 4 labels RTL: `1 مايو`, `10 مايو`, `20 مايو`, `30 مايو` |

**Data:** `FinanceDao.getDailyExpenseTotals` (last 30 days, expense `base_amount`).

**Gap:** Labels are dynamic `DateFormat.Md` unless seed uses May dates or UI uses fixed demo labels.

**Widget:** `DashboardExpenseChart`.

### G. Recent Transactions

| Element | Spec |
|---------|------|
| Header | «المعاملات الأخيرة» right; «المزيد» left blue |
| Row layout | Icon right (48px circle) → title + subtitle → amounts **left** |
| Expense | Orange basket icon; `USD 15.00-` red; `TRY 480.00` grey below |
| Income | Green banknote icon; `USD 1,500.00+` green |

**Data:** `transactions` — `primaryAmount` = `base_amount` in base code; `secondaryAmount` = original `amount` + `currency` when different.

**Widget:** `DashboardRecentTransactions` + `DashboardService`.

### H. FAB

| Property | Value |
|----------|--------|
| Position | `FloatingActionButtonLocation.startFloat` (bottom-left in RTL) |
| Style | 56dp circle, `#1A56BE`, white `+` 32px, elevation 6 |
| Action | `/transactions/add` |

---

## 2. Data Model (Tables & Fields for Visible UI)

All IDs are **UUID/text**. Amounts store **original + FX + base** where applicable.

### Required for dashboard (minimum)

#### `app_users`

| Field | UI use |
|-------|--------|
| `id` | FK for all rows |
| `full_name` | Profile (future) |
| `avatar_path` | Profile image (future) |

#### `user_settings`

| Field | UI use |
|-------|--------|
| `user_id` | Scope |
| `base_currency_id` | Label «الرصيد الإجمالي (USD)», all `base_amount` reporting |
| `language` | `ar` / `en` |
| `theme_mode` | Light/dark |

#### `currencies`

| Field | Mockup example |
|-------|----------------|
| `code` | USD, TRY, SYP, EUR |
| `name` | Arabic names in row |
| `symbol` | $, ₺, ل.س, € |
| `rate_to_base` | USD=1, TRY≈0.000031, SYP≈0.0000000667, EUR≈1.087 |
| `is_base` | Only USD `true` |

#### `wallets`

| Field | Notes |
|-------|--------|
| `currency_id` | One wallet per displayed currency |
| `opening_balance` | Tuned so **computed balance** matches mockup |
| `name`, `icon` | Optional display |

**Balance is not stored** — computed in `FinanceDao.computeWalletBalance()`.

#### `categories`

| Field | Mockup |
|-------|--------|
| `type` | `income` / `expense` |
| `name` | طعام، راتب |
| `icon`, `color` | Map to UI icons (future: read from DB) |

#### `transactions`

| Field | Mockup row |
|-------|------------|
| `type` | `expense` / `income` |
| `title` | بقالة المجد، راتب الشهر |
| `amount` | 480 TRY, 1500 USD, etc. |
| `currency_id` | FK |
| `exchange_rate` | Frozen at entry |
| `base_amount` | 15 USD, 1500 USD |
| `transaction_date` | Today / yesterday for subtitles |
| `wallet_id`, `category_id` | FK |

#### `debts` + `debt_payments`

| Field | Mockup |
|-------|--------|
| `type` | `i_owe` for «علي للآخرين» |
| `amount` / `base_amount` | 100 USD principal |
| `debt_payments.base_amount` | 50 → **outstanding 50 USD** |
| `notes` | Optional subtitle text |

#### `goals`

| Field | Mockup |
|-------|--------|
| `title` | شراء سيارة |
| `target_amount` | 15000 |
| `saved_amount` | 3600 → **24%** |
| `currency_id` | USD |

### Not shown on dashboard but in schema

`transfers`, `budgets`, `attachments`, `auth_local`, `security_settings` — keep for product scope; no seed required for 100% dashboard match.

### Derived (not tables)

| Metric | Formula |
|--------|---------|
| Total balance | Sum of wallet balances in base |
| Wallet balance | opening + income − expense ± transfers |
| Monthly income/expense | SUM(`base_amount`) WHERE month = current |
| Outstanding debt | SUM(debt `base_amount`) − SUM(payments `base_amount`) |
| Goal % | `saved_amount / target_amount * 100` |
| Chart points | Daily SUM(expense `base_amount`) / max |

---

## 3. Step-by-Step Seeding Plan

### Tool choice

| Option | Recommendation |
|--------|----------------|
| **Sider / DB browser** | Manual QA only — not reproducible |
| **`DatabaseSeedService`** | **Preferred** — versioned, transactional, runs on empty DB |
| **JSON import script** | Use `docs/seeds/dashboard-mockup.json` as source of truth; map to Dart seed |

### Prerequisites

1. Uninstall app or delete `lazarus.db` on emulator (fresh seed).
2. Ensure no Hive migration user exists before seed, OR use dedicated seed user id.
3. Run: `flutter pub get` → `dart run build_runner build` → `flutter run`.

### Step 1 — User & settings

```
user_id: seed-user-0001
full_name: مستخدم تجريبي
base_currency: USD (cur-usd-0001)
language: ar
```

### Step 2 — Currencies (rates tuned for mockup equivalents)

| code | rate_to_base | Target wallet balance (native) | ≈ base |
|------|--------------|----------------------------------|--------|
| USD | 1.0 | — | base |
| TRY | 0.000031 | 40,320 | 1,250 |
| SYP | 0.0000000667 | 18,750,000 | 1,250 |
| EUR | 1.087 | 1,150 | 1,250 |

### Step 3 — Wallets

Create one wallet per currency with `opening_balance` adjusted so that after seeded transactions, computed balance matches column amounts.

Suggested stable IDs (match `dashboard-mockup.json`):

- `wal-usd-cash`, `wal-try-cash`, `wal-syp-cash`, `wal-eur-cash`

### Step 4 — Categories

- `cat-food` → expense, طعام, icon 🛒  
- `cat-salary` → income, راتب, icon 💰  

### Step 5 — Transactions (current month)

| title | type | amount | currency | base_amount | date offset |
|-------|------|--------|----------|-------------|-------------|
| بقالة المجد | expense | 480 | TRY | 15 | today −2h |
| راتب الشهر | income | 1500 | USD | 1500 | yesterday 09:00 |
| مصروف متفرق | expense | 100 | USD | 100 | day 5 of month |

**Target monthly summary:** income **1500**, expense **250** (15 + 100 + additional 135 if needed).

### Step 6 — Debt

- Debt: `i_owe`, person أحمد, amount 100 USD, base 100  
- Payment: 50 USD → outstanding **50**  
- Dashboard subtitle: `l10n.dashboardDebtsOwedToOthers` («علي للآخرين») — not from `debts.notes` today

### Step 7 — Goal

- title: شراء سيارة  
- target: 15000, saved: 3600 → **24%**

### Step 8 — Chart (May demo)

Insert expense transactions on **May 1, 10, 20, 30** (current year) with varying `base_amount` so the spline has 4 visible peaks.

### Step 9 — Implement / refresh seed

1. Update `lib/database/seed/database_seed_service.dart` from `docs/seeds/dashboard-mockup.json`.
2. Optionally add `dart run tool/seed_dashboard.dart` for dev re-seed (delete DB + insert).
3. Call `seedIfEmpty()` from `LazarusDatabaseService.initialize()` (already wired).

### Step 10 — Auth note

Hive auth is separate. For demo UI only, seed user exists in SQL; app may still require normal registration unless bypassed for dev.

---

## 4. Validation Criteria & Test Cases (100/100 Scorecard)

### Visual (40 points)

| # | Criterion | Pass condition |
|---|-----------|----------------|
| V1 | Header layout | Logo left, title centered, bell+profile right |
| V2 | Balance typography | Split `USD` muted + large amount blue |
| V3 | Currency row | 3 columns TRY/SYP/EUR, dividers, `≈ USD` subtext |
| V4 | Summary colors | Green income, red expense, orange debt |
| V5 | Summary deltas | `+12% ↑` and `-5% ↓` visible when data > 0 |
| V6 | Goals RTL bar | 24% fill from right; car icon + title |
| V7 | Chart toggle | Daily selected; spline + gradient |
| V8 | Transactions | Icon right, amounts left, dual currency on expense |
| V9 | FAB | Bottom-left blue circle |
| V10 | Dividers | Light grey between sections |

### Data accuracy (40 points)

| # | Criterion | Expected value | Source |
|---|-----------|----------------|--------|
| D1 | Total balance | USD 1,250.00 (±0.01) | Wallet aggregates |
| D2 | TRY column | TRY 40,320.00 | Wallet TRY |
| D3 | SYP column | SYP 18,750,000 | Wallet SYP |
| D4 | EUR column | EUR 1,150.00 | Wallet EUR |
| D5 | Monthly income | USD 1,500 | Transactions month |
| D6 | Monthly expense | USD 250 | Transactions month |
| D7 | Debts | USD 50 | debts − payments |
| D8 | Goal progress | 24% | goals |
| D9 | Recent tx 1 | USD 15.00−, TRY 480 | transactions |
| D10 | Recent tx 2 | USD 1,500.00+ | transactions |

### Technical (20 points)

| # | Criterion | Pass condition |
|---|-----------|----------------|
| T1 | No mock file | `dashboard_mock_data.dart` unused |
| T2 | Offline | Data from `lazarus.db` only |
| T3 | Refresh | Pull-to-refresh reloads providers + snapshot |
| T4 | RTL | `flutter run` with locale `ar` |
| T5 | Build | `flutter build apk --debug` succeeds |

### Automated checks (recommended)

```dart
// test/dashboard_seed_contract_test.dart (future)
test('seed produces mockup totals', () async {
  final db = await LazarusDatabase.open();
  final dao = db.financeDao;
  final income = await dao.sumTransactionsBaseAmount(..., type: 'income', ...);
  expect(income, closeTo(1500, 0.01));
});
```

### Manual QA script

1. Fresh install → dashboard loads without spinner stuck.  
2. Compare side-by-side with PNG for 10 sections above.  
3. Toggle chart weekly → data switches.  
4. Tap FAB → navigates to add transaction placeholder.  
5. Change device language EN → strings from l10n, layout still RTL if app forces `ar`.

---

## 5. Assumptions & Constraints

### Tech stack

- **Flutter** 3.44+, Dart 3.12+  
- **State:** Provider  
- **Routing:** GoRouter  
- **DB:** Drift 2.33 + SQLite `lazarus.db` (`sqlite3` 3.x hooks)  
- **Auth (current):** Hive `AppSettings` + PIN flow; SQL `auth_local` seeded but not fully wired  
- **i18n:** `lib/l10n/app_ar.arb`, `app_en.arb`

### Database

- Offline-first; no cloud sync in phase 1  
- Single active user (`getActiveUserId()` first non-deleted row)  
- Historical FX frozen per transaction (`exchange_rate` immutable)  
- Wallet balance **never** stored denormalized

### Data sources

| UI section | Source | Not from |
|------------|--------|----------|
| Balance & currencies | Lazarus wallets + transactions | Hive |
| Monthly summary | Lazarus transactions | Hardcoded (except %) |
| Debts | Lazarus debts | Static string only for subtitle |
| Goals | Lazarus goals | Mock list |
| Chart | Lazarus transactions | Mock points |
| Recent tx | Lazarus transactions | Mock list |

### Known gaps to reach 100/100

1. **Month-over-month %** (+12% / −5%): UI placeholder — needs prior-month query or `dashboard_metrics` table.  
2. **Debt subtitle** «علي للآخرين»: i18n key, not `debts.notes`.  
3. **Category/goal icons**: Hardcoded in `DashboardService` — should use `categories.icon` / `goals` metadata.  
4. **SYP/EUR wallets**: Seed must add wallets + balances or currency row shows fewer than 3 columns.  
5. **Chart May labels**: Dynamic dates unless May seed data or label override for demo.  
6. **Total 1,250**: Requires balancing opening balances + transactions across 4 currencies — tune in seed JSON.

### Out of scope for dashboard parity

- Notifications bell action  
- Add goal / More links (placeholders)  
- Profile screen content  
- Cloud backup, multi-user switcher  

---

## Implementation Checklist (Engineering)

- [ ] Align `database_seed_service.dart` with `docs/seeds/dashboard-mockup.json`  
- [ ] Add `wal-syp-cash`, `wal-eur-cash` and balance tuning  
- [ ] Fix expense total to **250** USD for current month  
- [ ] Add May chart seed transactions  
- [ ] Implement prior-month % in `DashboardService` (remove hardcoded 12/5)  
- [ ] Map `categories.icon` / `categories.color` to transaction tiles  
- [ ] Add `goals.icon` column (optional migration) or icon map by title  
- [ ] Document in `docs/project-progress.md` when complete  

---

## Related files

| Purpose | Path |
|---------|------|
| Seed JSON | `docs/seeds/dashboard-mockup.json` |
| Seed code | `lib/database/seed/database_seed_service.dart` |
| Schema | `lib/database/tables/schema_tables.dart` |
| Dashboard UI | `lib/features/dashboard/` |
| Data load | `lib/services/dashboard_service.dart` |
| DB docs | `docs/database-lazarus.md` |
