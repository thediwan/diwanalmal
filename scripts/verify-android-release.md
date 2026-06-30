# Verify Android release APK (F-Droid preflight)

Run after building a release APK on a machine with Android SDK installed.

## Build

```bash
git submodule update --init --recursive
.flutter/bin/flutter pub get --enforce-lockfile
.flutter/bin/dart run build_runner build --delete-conflicting-outputs
.flutter/bin/flutter gen-l10n
.flutter/bin/flutter build apk --release --target-platform android-arm64
```

## Verify package name

```bash
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep package
# Expected: package: name='org.thediwan.diwanalmal'
```

## Verify permissions (no INTERNET in release)

```bash
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

Expected permissions:

- `android.permission.USE_BIOMETRIC`
- `android.permission.USE_FINGERPRINT`
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.WAKE_LOCK`

Must **not** include `android.permission.INTERNET`.

## Verify unsigned release

Release builds must not be signed with debug keys. F-Droid signs official builds.

```bash
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
# Unsigned or min-signed is OK for local testing; F-Droid re-signs.
```
