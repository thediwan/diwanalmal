# F-Droid Store Metadata

Triple-T / Fastlane layout used by F-Droid for in-repo store descriptions.

## Locales

| Locale | Path | Status |
|--------|------|--------|
| English | `en-US/` | Descriptions complete |
| Arabic | `ar/` | Descriptions complete |

## Screenshots

UI screenshots are generated from a Windows integration test with demo data:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_fdroid_screenshots.ps1
```

Uses `--dart-define=SEED_DEMO=true` and golden files at 1080×1920.

## Icon

`images/icon.png` must be **512×512 PNG**. Currently copied from
`assets/icon/app_icon.png` — resize if dimensions differ.

## Feature graphic

Optional `images/featureGraphic.png` at **1024×500** for F-Droid client display.
