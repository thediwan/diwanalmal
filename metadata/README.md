# F-Droid Store Metadata

Triple-T / Fastlane layout used by F-Droid for in-repo store descriptions.

## Locales

| Locale | Path | Status |
|--------|------|--------|
| English | `en-US/` | Descriptions complete |
| Arabic | `ar/` | Descriptions complete |

## Screenshots

Replace placeholder images in `*/images/phoneScreenshots/` with **release-build UI
screenshots** before opening the fdroiddata merge request:

1. Build: `flutter build apk --release`
2. Install on emulator or device (1080×1920 or 1080×2340)
3. Capture: dashboard, transactions, wallets, reports, settings/backup
4. Capture Arabic locale shots for `metadata/ar/images/phoneScreenshots/`

Recommended filenames: `01_dashboard.png`, `02_transactions.png`, etc.

## Icon

`images/icon.png` must be **512×512 PNG**. Currently copied from
`assets/icon/app_icon.png` — resize if dimensions differ.

## Feature graphic

Optional `images/featureGraphic.png` at **1024×500** for F-Droid client display.
