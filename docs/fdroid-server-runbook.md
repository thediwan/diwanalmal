# F-Droid Server Local Build Runbook

Validate the Diwan Al-Mal build recipe locally before opening a fdroiddata merge request.

## Prerequisites

- Linux VM or Docker (Debian/Ubuntu recommended — matches F-Droid builders)
- [fdroidserver](https://gitlab.com/fdroid/fdroidserver) installed
- Git, Java 17, Android SDK (installed by fdroidserver setup)

## 1. Install fdroidserver

```bash
sudo apt install fdroidserver
# Or: pip install fdroidserver
fdroid --version
```

## 2. Clone fdroiddata and add recipe

```bash
git clone https://gitlab.com/fdroid/fdroiddata.git
cd fdroiddata
cp /path/to/diwanalmal/fdroid/org.thediwan.diwanalmal.yml metadata/
```

Ensure the source repo tag `v1.0.0` exists on GitHub before building.

## 3. Lint

```bash
fdroid lint org.thediwan.diwanalmal
```

Fix any reported issues in the recipe or source repo.

## 4. Build

```bash
fdroid build org.thediwan.diwanalmal --verbose
```

Common Flutter fixes if build fails:

| Issue | Fix |
|-------|-----|
| Flutter not found | Ensure `submodules: true` and `.flutter` submodule in source repo |
| pub get fails | Use `--enforce-lockfile`; commit `pubspec.lock` |
| Drift missing generated files | Add `dart run build_runner build` to prebuild |
| Wrong APK path | Check log for actual output path; update `output:` |
| SDK path embedded | Follow [F-Droid reproducible builds doc](https://f-droid.org/docs/Reproducible_Builds/) |

## 5. Verify APK permissions

```bash
aapt dump permissions ~/fdroiddata/tmp/org.thediwan.diwanalmal-*/*.apk
```

**Expected:** `USE_BIOMETRIC`, `USE_FINGERPRINT`, `POST_NOTIFICATIONS`,
`RECEIVE_BOOT_COMPLETED`, `WAKE_LOCK`

**Must NOT include:** `INTERNET` (release build)

## 6. Smoke test on device

Install the built APK on Android 8+ and verify:

- [ ] Registration and PIN setup
- [ ] Add wallet and transaction
- [ ] Dashboard loads
- [ ] Backup screen opens
- [ ] Biometric unlock (if hardware available)

## 7. Next step

Open fdroiddata MR — see [fdroid-release-runbook.md](fdroid-release-runbook.md).
