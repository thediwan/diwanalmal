# F-Droid Publishing Plan — Diwan Al-Mal

> **Status:** Ready for fdroidserver trial & fdroiddata MR  
> **Last updated:** June 2026  
> **Target:** First listing on [F-Droid](https://f-droid.org/)  
> **License:** GPL-3.0-or-later ([`LICENSE`](../LICENSE))

This document is the internal checklist for publishing **Diwan Al-Mal** to F-Droid. It follows the official [Submitting to F-Droid Quick Start Guide](https://f-droid.org/docs/Submitting_to_F-Droid_Quick_Start_Guide/) and the [Flutter build template](https://gitlab.com/fdroid/fdroiddata/-/blob/master/templates/build-flutter.yml) maintained in `fdroiddata`.

---

## 1. Goals

| Goal | Rationale |
|------|-----------|
| List on F-Droid main repo | Reach privacy-conscious Android users without Google Play |
| FOSS-only dependency tree | F-Droid policy requirement |
| Reproducible builds from v1 | Best practice; hard to adopt later without user reinstall |
| F-Droid signing from first release | Avoid maintaining a separate release keystore; F-Droid builds and signs |
| Store metadata in this repo | Required before inclusion; follows Fastlane / Triple-T layout |

---

## 2. Current readiness

| Requirement | Status | Notes |
|-------------|--------|-------|
| Public source repo | ✅ Done | `https://github.com/thediwan/diwanalmal` |
| FOSS license file | ✅ Done | GPL-3.0-or-later in [`LICENSE`](../LICENSE) |
| No Firebase / GMS | ✅ Clean | No proprietary Google mobile services in app code |
| `pubspec.lock` committed | ✅ Done | Required for `--enforce-lockfile` builds |
| Stable application ID | ✅ Done | `org.thediwan.diwanalmal` |
| Release signing strategy | ✅ Done | F-Droid signs; debug signing removed from release |
| Flutter SDK pinned | ✅ Done | Submodule `.flutter` @ 3.44.1, [`.flutter-version`](../.flutter-version) |
| F-Droid store metadata | ✅ Done | [`metadata/en-US/`](../metadata/en-US/), [`metadata/ar/`](../metadata/ar/) |
| Reproducible build setup | ✅ Done | `dependenciesInfo { includeInApk false }`, minSdk 21 |
| GitHub release APK workflow | ✅ Done | [`.github/workflows/release.yml`](../.github/workflows/release.yml) |
| CI workflow | ✅ Done | [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) |
| Dependency audit | ✅ Done | [`docs/third-party-licenses.md`](third-party-licenses.md) |
| NOTICE / font licenses | ✅ Done | [`NOTICE`](../NOTICE), [`assets/fonts/LICENSE.md`](../assets/fonts/LICENSE.md) |
| fdroiddata recipe draft | ✅ Done | [`fdroid/org.thediwan.diwanalmal.yml`](../fdroid/org.thediwan.diwanalmal.yml) |
| Local fdroidserver build | ⏳ Manual | Requires Linux + `fdroidserver` — see [`fdroid-server-runbook.md`](fdroid-server-runbook.md) |
| Release screenshots | ✅ Done | Generated via `scripts/generate_fdroid_screenshots.ps1` |
| Git tag v1.0.0 | ✅ Done | Pushed to GitHub |
| fdroiddata MR submitted | ⏳ Manual | Run [`scripts/submit-fdroiddata-mr.sh`](../scripts/submit-fdroiddata-mr.sh) |
| GPL source headers | ⏳ Optional | Recommended for new/changed files |

---

## 3. Blockers (must fix before submission)

### 3.1 Application ID

**Current:** `org.thediwan.diwanalmal` ✅

The application ID is set for F-Droid and store releases. Do not change it after the first public Android release.

**Acceptance criteria:** `flutter build apk --release` produces an APK with `org.thediwan.diwanalmal`; no `com.example` references remain.

---

### 3.2 Signing strategy

**Current:** F-Droid builds and signs (Strategy A) ✅

Release builds no longer use debug signing. See [android/app/build.gradle](../android/app/build.gradle).

GitHub release APKs (`.github/workflows/release.yml`) are for maintainer testing only.

---

### 3.3 Flutter SDK pinning

**Current:** `.flutter` git submodule @ **3.44.1** (commit `924134a44c`) ✅

Files:
- [`.gitmodules`](../.gitmodules)
- [`.flutter-version`](../.flutter-version)

Clone with: `git clone --recurse-submodules ...`

---

### 3.4 Android build.gradle adjustments

**Current:** Applied ✅

- `dependenciesInfo { includeInApk false }`
- `minSdk = 21`
- Unsigned release build type

Verify release APK permissions: [`scripts/verify-android-release.md`](../scripts/verify-android-release.md)

---

## 4. Dependency audit (FOSS compliance)

F-Droid rejects apps with non-free dependencies (e.g. Firebase, Google Play Services SDK).

### Direct dependencies to verify

| Package | FOSS? | F-Droid notes |
|---------|-------|---------------|
| `flutter`, `drift`, `provider`, `go_router` | ✅ | Standard |
| `local_auth` | ✅ | Uses Android Biometric API, no GMS |
| `workmanager` | ✅ | Background tasks |
| `flutter_local_notifications` | ✅ | |
| `image_picker`, `file_picker` | ✅ | |
| `share_plus`, `pdf`, `printing` | ✅ | |
| `hive`, `sqlite3` | ✅ | |

### Action

Completed — see [`docs/third-party-licenses.md`](third-party-licenses.md) and [`NOTICE`](../NOTICE).

Run [fdroidscanner](https://gitlab.com/fdroid/fdroidscanner) on release APK before fdroiddata MR for automated verification.

---

## 5. Store metadata (in-repo, pre-submission)

F-Droid reads description metadata from the **source repo** before inclusion. Use the [Triple-T / Fastlane directory layout](https://f-droid.org/docs/Submitting_to_F-Droid_Quick_Start_Guide/) — tooling not required.

### Target structure

```
metadata/
└── en-US/
    ├── title.txt                 # Max ~50 chars: "Diwan Al-Mal"
    ├── short_description.txt     # Max 80 chars
    ├── full_description.txt      # Long description (FOSS, offline, Arabic-first)
    └── images/
        ├── icon.png              # 512×512 PNG
        ├── featureGraphic.png    # 1024×500 (optional but recommended)
        ├── phoneScreenshots/
        │   ├── 1_en.png
        │   └── ...
        └── sevenInchScreenshots/   # Optional tablet shots
```

Add `metadata/ar/` later for Arabic store listing (F-Droid supports multiple locales).

### Copy guidelines

- Lead with **privacy** (local-only data, no account server)
- Mention **offline-first**, **multi-currency**, **Arabic / RTL**
- State **GPL-3.0-or-later** license
- Do not claim features that are not shipped yet (see README roadmap)

### Screenshots needed

| Screen | Purpose |
|--------|---------|
| Dashboard | Hero / balance overview |
| Transactions list | Core daily use |
| Wallet detail | Multi-currency |
| Reports | Differentiator |
| Settings / backup | Privacy & trust |

Capture from release build on a clean device or emulator (1080×1920 or 1080×2340 PNG).

---

## 6. Build & release pipeline

### 6.1 GitHub Actions workflow (to add)

Create `.github/workflows/release.yml`:

1. Trigger on tag `v*`
2. Pin Flutter version (same as F-Droid recipe)
3. Run `flutter pub get`, `dart run build_runner build`, `flutter gen-l10n`
4. Run `flutter analyze` and `flutter test`
5. Build `flutter build apk --release --split-per-abi` (or single ABI for F-Droid recipe)
6. Attach APK(s) to GitHub Release with deterministic names, e.g. `diwanalmal-<versionCode>-arm64-v8a.apk`

### 6.2 Local release checklist

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

---

## 7. F-Droid metadata MR (`fdroiddata`)

Submission is a merge request to [gitlab.com/fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata).

### 7.1 New file

`metadata/org.thediwan.diwanalmal.yml` (name follows final application ID)

### 7.2 Draft recipe (starting point)

Adapt from [templates/build-flutter.yml](https://gitlab.com/fdroid/fdroiddata/-/blob/master/templates/build-flutter.yml):

```yaml
Categories:
  - Money

License: GPL-3.0-or-later
SourceCode: https://github.com/thediwan/diwanalmal
IssueTracker: https://github.com/thediwan/diwanalmal/issues
WebSite: https://github.com/thediwan/diwanalmal

Summary: Offline-first personal finance manager
Description: |-
  Diwan Al-Mal is a privacy-first personal finance app. All data stays on
  your device in a local SQLite database. Supports Arabic (RTL), English,
  multi-currency wallets, budgets, goals, and monthly reports.

RepoType: git
Repo: https://github.com/thediwan/diwanalmal

Builds:
  - versionName: '1.0.0'
    versionCode: 1
    commit: v1.0.0   # tag after first release
    submodules: true  # if using .flutter submodule
    output: build/app/outputs/flutter-apk/app-release.apk
    rm:
      - ios
      - linux
      - macos
      - web
      - windows
    prebuild:
      - export PUB_CACHE=$(pwd)/.pub-cache
      - .flutter/bin/flutter config --no-analytics
      - .flutter/bin/flutter pub get --enforce-lockfile
      - .flutter/bin/dart run build_runner build --delete-conflicting-outputs
      - .flutter/bin/flutter gen-l10n
    scandelete:
      - .pub-cache
    build:
      - .flutter/bin/flutter build apk --release --target-platform android-arm64

AutoUpdateMode: Version
UpdateCheckMode: Tags
CurrentVersion: '1.0.0'
CurrentVersionCode: 1
```

Adjust `output`, ABI splits, and Flutter checkout steps after local `fdroidserver` trial build.

### 7.3 Submission steps

1. Fork `fdroiddata` on GitLab
2. Add YAML + run `fdroid lint org.thediwan.diwanalmal`
3. Open MR with test build logs
4. Respond to reviewer feedback (common: permissions justification, reproducibility, metadata wording)
5. After merge, app appears in next F-Droid repo update cycle

---

## 8. Permissions justification (for reviewers)

Document in MR description why each permission is needed:

| Permission | Reason |
|------------|--------|
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Optional app unlock |
| `POST_NOTIFICATIONS` | Backup completion & report reminders |
| `RECEIVE_BOOT_COMPLETED` | Reschedule WorkManager backup after reboot |
| `WAKE_LOCK` | WorkManager background tasks |

No `INTERNET` permission is required for core app function (offline-first) — verify merged manifest does not add it unnecessarily via plugins.

---

## 9. GPL compliance checklist

| Item | Action |
|------|--------|
| LICENSE in repo root | ✅ Done |
| README license section | ✅ Done |
| `license:` in `pubspec.yaml` | ✅ Done |
| NOTICE file | ✅ Done |
| Third-party licenses doc | ✅ Done |
| Font license doc | ✅ Done — [`assets/fonts/LICENSE.md`](../assets/fonts/LICENSE.md) |
| Source offer | GitHub repo satisfies “source available” |
| Corresponding source for releases | Tag each release; source at tag must build |
| License headers in source files | Add SPDX header to new files; batch-add to existing over time |

---

## 10. Implementation timeline

| Phase | Tasks | Owner | Target |
|-------|-------|-------|--------|
| **0 — Legal** | GPL license, README, NOTICE, third-party licenses | Done | ✅ |
| **1 — Android identity** | Application ID, package move | Done | ✅ |
| **2 — Build hardening** | Flutter submodule, dependenciesInfo, release Gradle | Done | ✅ |
| **3 — Metadata** | `metadata/en-US/`, `metadata/ar/`, icon | Done | ✅ |
| **4 — CI** | GitHub Actions CI + release workflows, CHANGELOG | Done | ✅ |
| **5 — Local F-Droid test** | fdroidserver build in VM / Docker | Manual | See runbook |
| **6 — fdroiddata MR** | Submit recipe, address review | Manual | See runbook |
| **7 — Post-release** | Monitor issues, version bumps | Ongoing | See runbook |

---

## 11. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Changing app ID breaks existing installs | Change before any public release; never after F-Droid v1 |
| Reproducible build fails (Flutter `.so` diffs) | Pin Flutter + path; follow [F-Droid reproducible builds doc](https://f-droid.org/docs/Reproducible_Builds/) |
| Review delay | Complete metadata + permission docs upfront |
| Non-FOSS transitive dep flagged | Audit early with fdroidscanner |
| Font licensing unclear | Verify Qomra / Alyamama allow redistribution in OSS app |
| `com.example` rejection | Resolved — using `org.thediwan.diwanalmal` |

---

## 12. Next actions (immediate)

1. ~~**Decide final application ID**~~ — `org.thediwan.diwanalmal` ✅
2. ~~**Decide signing strategy**~~ — F-Droid-signed v1 ✅
3. ~~**Add Flutter submodule**~~ — `.flutter` @ 3.44.1 ✅
4. ~~**Patch `android/app/build.gradle`**~~ — `dependenciesInfo`, minSdk 21 ✅
5. ~~**Scaffold `metadata/en-US/` and `metadata/ar/`**~~ ✅
6. ~~**Add `.github/workflows/`**~~ — CI + release ✅
7. ~~**Replace placeholder screenshots**~~ ✅ — `scripts/generate_fdroid_screenshots.ps1`
8. ~~**Tag `v1.0.0` and push**~~ ✅
9. **Run local `fdroid build`** — [`fdroid-server-runbook.md`](fdroid-server-runbook.md) (Linux + fdroidserver)
10. **Open fdroiddata MR** — [`scripts/submit-fdroiddata-mr.sh`](../scripts/submit-fdroiddata-mr.sh)

---

## 13. References

- [F-Droid Inclusion Policy](https://f-droid.org/docs/Inclusion_Policy/)
- [Submitting to F-Droid Quick Start](https://f-droid.org/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Reproducible Builds](https://f-droid.org/docs/Reproducible_Builds/)
- [Flutter build template (fdroiddata)](https://gitlab.com/fdroid/fdroiddata/-/blob/master/templates/build-flutter.yml)
- [orgro — example Flutter submodule setup](https://github.com/amake/orgro)
- [GPL-3.0 FAQ](https://www.gnu.org/licenses/gpl-faq.html)
