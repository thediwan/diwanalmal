# F-Droid Publishing Plan — Diwan Al-Mal

> **Status:** Planning  
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
| Release signing strategy | ❌ Blocker | Release build uses debug keystore |
| Flutter SDK pinned | ❌ Missing | No `.fvm/` or CI pin yet |
| F-Droid store metadata | ❌ Missing | No `metadata/` or `fastlane/` descriptions |
| Reproducible build setup | ❌ Missing | No pinned paths, no `dependenciesInfo` fix |
| GitHub release APK workflow | ❌ Missing | No `.github/workflows/` |
| Dependency audit | ⏳ Pending | Manual review of all pub + native deps |
| GPL source headers | ⏳ Optional | Recommended for `.dart` / native files |

---

## 3. Blockers (must fix before submission)

### 3.1 Application ID

**Current:** `org.thediwan.diwanalmal` ✅

The application ID is set for F-Droid and store releases. Do not change it after the first public Android release.

**Acceptance criteria:** `flutter build apk --release` produces an APK with `org.thediwan.diwanalmal`; no `com.example` references remain.

---

### 3.2 Signing strategy

**Current:** `signingConfig = signingConfigs.debug` in release (`android/app/build.gradle`).

For F-Droid, choose one path and commit to it for the first published version:

| Strategy | Pros | Cons |
|----------|------|------|
| **A. F-Droid builds & signs (recommended for new apps)** | No keystore to manage; aligns with F-Droid trust model | You do not ship your own signed APK to users |
| **B. Reproducible builds with upstream APK** | You publish signed APKs; F-Droid verifies they match source | Must set up reproducible toolchain from day one |

**Recommendation:** Strategy **A** for v1 — let F-Droid sign. Remove debug signing from release; do not commit keystores.

If choosing **B** later, add to `fdroiddata` metadata:

```yaml
AllowedAPKSigningKeys: <SHA-256 fingerprint of your release key>
Binaries: https://github.com/thediwan/diwanalmal/releases/download/v<version>/app-release.apk
```

---

### 3.3 Flutter SDK pinning

F-Droid builds must reproduce your exact Flutter version. Pick one method:

**Option A — Git submodule (preferred by F-Droid Flutter template)**

```bash
git submodule add https://github.com/flutter/flutter.git .flutter
cd .flutter && git checkout <tag>   # e.g. 3.32.5
```

**Option B — Document version in CI and read it in `fdroiddata` prebuild**

Add `.github/workflows/release.yml` with a pinned `flutter-version:` and reference it from the F-Droid recipe (see upstream template).

**Option C — FVM**

Add `.fvm/fvm_config.json` and document that maintainers must use the same version.

**Acceptance criteria:** Two builds on different machines with the same tag produce identical APK hashes (after reproducibility fixes in §3.5).

---

### 3.4 Android build.gradle adjustments

Add for reproducibility ([Android dependency info block](https://developer.android.com/build/dependencies#dependency-info-play)):

```gradle
android {
    dependenciesInfo {
        includeInApk false
    }
}
```

Also verify:

- `minSdk` is explicit and documented (currently from Flutter defaults)
- No proprietary Maven repos required at build time (Aliyun mirrors in Gradle are OK as fallbacks but F-Droid builders use standard repos)

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

Run [F-Droid scanner](https://gitlab.com/fdroid/fdroidscanner) locally or rely on F-Droid CI after MR. Document any flagged transitive deps and replace if needed.

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
| Source offer | GitHub repo satisfies “source available” |
| Corresponding source for releases | Tag each release; source at tag must build |
| License headers in source files | Add SPDX header to new files; batch-add to existing over time |
| Third-party notices | Consider `NOTICE` or `docs/third-party-licenses.md` for bundled fonts (Qomra, Alyamama) — confirm font licenses allow GPL app distribution |

---

## 10. Implementation timeline

| Phase | Tasks | Owner | Target |
|-------|-------|-------|--------|
| **0 — Legal** | GPL license, README | Done | ✅ |
| **1 — Android identity** | ~~Final application ID, package move~~ ✅ Done | Dev | Week 1 |
| **2 — Build hardening** | Pin Flutter, `dependenciesInfo`, release Gradle cleanup | Dev | Week 1–2 |
| **3 — Metadata** | `metadata/en-US/`, screenshots, icon 512px | Design + Dev | Week 2 |
| **4 — CI** | GitHub Actions release on tag | Dev | Week 2 |
| **5 — Local F-Droid test** | `fdroidserver` build in VM / Docker | Dev | Week 3 |
| **6 — fdroiddata MR** | Submit recipe, address review | Dev | Week 3–4 |
| **7 — Post-release** | Monitor issues, version bumps, UpdateCheckMode tags | Maintainers | Ongoing |

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
2. **Decide signing strategy** — recommend F-Droid-signed v1
3. **Add Flutter submodule** at `.flutter` and pin version tag
4. **Patch `android/app/build.gradle`** — `dependenciesInfo { includeInApk false }`
5. **Scaffold `metadata/en-US/`** with descriptions (screenshots can follow)
6. **Add `.github/workflows/release.yml`** for tagged releases
7. **Capture 4–6 screenshots** from release build
8. **Open fdroiddata MR** after a successful local `fdroid build`

---

## 13. References

- [F-Droid Inclusion Policy](https://f-droid.org/docs/Inclusion_Policy/)
- [Submitting to F-Droid Quick Start](https://f-droid.org/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Reproducible Builds](https://f-droid.org/docs/Reproducible_Builds/)
- [Flutter build template (fdroiddata)](https://gitlab.com/fdroid/fdroiddata/-/blob/master/templates/build-flutter.yml)
- [orgro — example Flutter submodule setup](https://github.com/amake/orgro)
- [GPL-3.0 FAQ](https://www.gnu.org/licenses/gpl-faq.html)
