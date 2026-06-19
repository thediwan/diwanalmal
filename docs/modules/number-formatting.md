# Number formatting

> **Last updated:** June 19, 2026  
> **Scope:** Monetary amount display across the app and keypad entry on transaction forms.

---

## Overview

Amounts are formatted using a user preference stored in Hive (`AppSettings.amountFormatStyle`).  
The user selects the style on **Settings → Appearance** (`/settings/appearance`). Default is **Western** (`1,234.56`).

| Style | Example | Thousands | Decimal |
|-------|---------|-----------|---------|
| `western` | `1,234.56` | `,` | `.` |
| `european` | `1.234,56` | `.` | `,` |
| `plain` | `1234.56` | *(none)* | `.` |

---

## Architecture

```
AppSettings (Hive)
    └── amountFormatStyle → AmountFormatStyle enum
            ↓
SettingsProvider.setAmountFormatStyle()
            ↓
CurrencyFormatter.configureFromStyle()
NumberFormatPreferences.current
            ↓
CurrencyFormatter.format*()  — lists, dashboard, wallets
TransactionAmountInput.display — live keypad entry
```

### Key files

| File | Role |
|------|------|
| `lib/models/amount_format_style.dart` | Enum + Hive index mapping |
| `lib/models/app_settings.dart` | Persists `amountFormatStyleIndex` |
| `lib/providers/settings_provider.dart` | `amountFormatStyle` getter + `setAmountFormatStyle()` |
| `lib/core/helpers/number_format_preferences.dart` | Active preferences + `intl` formatters |
| `lib/core/helpers/currency_formatter.dart` | App-wide amount formatting API |
| `lib/features/transactions/widgets/transaction_numeric_keypad.dart` | Keypad + `TransactionAmountInput` |
| `lib/features/profile/appearance_screen.dart` | User-facing amount format picker |

---

## Transaction amount entry

The numeric keypad enters amounts in **whole currency units**, not cents.

| Input | Display | Stored value |
|-------|---------|--------------|
| `2` → `0` | `20` | `20.0` |
| `2` → `0` → `.` → `1` | `20.1` | `20.1` |
| `00` on `2` | `200` | `200.0` |

- Bottom row: `00` · **thousands separator** (toggle display grouping, default off) · **decimal separator** · `0` · backspace  
- Default entry display is plain digits (`5000` not `5,000`); tap the separator key to toggle grouping (`5,000`) without changing the stored value.
- Decimal key label follows the user's format (`.` or `,`).  
- Up to 2 fraction digits.

---

## Settings integration

Implemented on **`/settings/appearance`** (`AppearanceScreen`):

1. Read `context.watch<SettingsProvider>().amountFormatStyle`
2. On change, call `setAmountFormatStyle(AmountFormatStyle.western)` (etc.)
3. l10n keys: `settingsAmountFormat`, `settingsAmountFormatWestern`, …

No app restart required — `CurrencyFormatter` updates in memory immediately.

For theme mode and color palettes on the same screen, see `docs/modules/color-palettes-and-theming.md`.

---

## API usage

```dart
// Display (uses current user preference)
CurrencyFormatter.formatAmountOnly(1250.5);
CurrencyFormatter.formatWithCode(1250.5, 'USD');

// Change preference (from settings screen)
await settingsProvider.setAmountFormatStyle(AmountFormatStyle.european);
```
