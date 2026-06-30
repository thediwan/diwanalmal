# Third-Party Licenses — Diwan Al-Mal

Summary of **direct** dependencies from [`pubspec.yaml`](../pubspec.yaml). Transitive
dependencies inherit compatible FOSS licenses via pub.dev. No Firebase, Google Play
Services, or other proprietary mobile SDKs are used.

Last reviewed: June 2026

## Application license

Diwan Al-Mal — **GPL-3.0-or-later** ([LICENSE](../LICENSE))

## Direct dependencies

| Package | Version (lockfile) | License | Notes |
|---------|-------------------|---------|-------|
| flutter | SDK | BSD-3-Clause | Flutter framework |
| flutter_localizations | SDK | BSD-3-Clause | Flutter i18n |
| cupertino_icons | 1.0.8 | MIT | Icons |
| hive | 2.2.3 | Apache-2.0, BSD-3-Clause | Local key-value store |
| hive_flutter | 1.1.0 | Apache-2.0, BSD-3-Clause | Hive Flutter integration |
| provider | 6.1.2+ | MIT | State management |
| go_router | 14.8.1+ | BSD-3-Clause | Navigation |
| uuid | 4.5.1+ | MIT | UUID generation |
| intl | 0.20.2 | BSD-3-Clause | Formatting |
| local_auth | 2.3.0 | BSD-3-Clause | Biometric auth (no GMS) |
| local_auth_android | 1.0.56+ | BSD-3-Clause | Android biometrics |
| local_auth_darwin | 1.6.1+ | BSD-3-Clause | iOS/macOS biometrics |
| drift | 2.33.0 | MIT | SQLite ORM |
| drift_flutter | 0.3.0 | MIT | Drift Flutter integration |
| path_provider | 2.1.5+ | BSD-3-Clause | File paths |
| path | 1.9.0+ | BSD-3-Clause | Path utilities |
| sqlite3 | 3.3.2 | MIT | SQLite bindings |
| package_info_plus | 8.3.1+ | BSD-3-Clause | App version info |
| image_picker | 1.1.2+ | Apache-2.0, BSD-3-Clause | Camera/gallery |
| fl_chart | 1.2.0+ | MIT | Charts |
| workmanager | 0.9.0 | MIT | Background tasks |
| flutter_local_notifications | 19.5.0+ | BSD-3-Clause | Local notifications |
| timezone | 0.10.1 | BSD-2-Clause | Timezone data |
| file_picker | 8.3.7+ | MIT | File picker |
| share_plus | 10.1.4+ | BSD-3-Clause | System share sheet |
| archive | 3.6.1 | Apache-2.0 | Backup archive (zip) |
| pdf | 3.12.0+ | Apache-2.0 | PDF generation |
| printing | 5.14.3+ | Apache-2.0 | PDF printing/share |

## Dev dependencies (not shipped in release APK)

| Package | License |
|---------|---------|
| flutter_test | BSD-3-Clause |
| flutter_lints | BSD-3-Clause |
| flutter_launcher_icons | MIT |
| drift_dev | MIT |
| build_runner | BSD-3-Clause |

## Bundled assets

| Asset | License |
|-------|---------|
| Qomra.ttf | See [assets/fonts/LICENSE.md](../assets/fonts/LICENSE.md) |
| Alyamama.ttf | See [assets/fonts/LICENSE.md](../assets/fonts/LICENSE.md) |
| App icons & logos | GPL-3.0-or-later (same as application) |

## F-Droid compliance audit

| Check | Result |
|-------|--------|
| Firebase / GMS | Not used |
| Proprietary analytics | Not used |
| Non-free network SDKs | Not used |
| `INTERNET` in release manifest | Not declared in `main` manifest |
| FOSS build tools | Flutter + Gradle (F-Droid builds from source) |

Run [fdroidscanner](https://gitlab.com/fdroid/fdroidscanner) on release APK before
fdroiddata submission for automated verification.

## Corresponding source

Source code for each release tag is available at:
https://github.com/thediwan/diwanalmal
