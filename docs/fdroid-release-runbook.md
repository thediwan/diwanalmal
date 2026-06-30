# F-Droid Release & Maintenance Runbook

Post-publication workflow for Diwan Al-Mal on F-Droid.

## Signing model

**F-Droid builds and signs** official APKs (Strategy A). GitHub release APKs from
`.github/workflows/release.yml` are for maintainer testing only.

## First-time submission checklist

1. [ ] Replace placeholder screenshots in `metadata/*/images/phoneScreenshots/`
2. [ ] Confirm `metadata/en-US/images/icon.png` is 512×512 PNG
3. [ ] Run local `fdroid build` — see [fdroid-server-runbook.md](fdroid-server-runbook.md)
4. [ ] Commit and push all changes to `main` on GitHub
5. [ ] Create annotated tag:

   ```bash
   git tag -a v1.0.0 -m "Release 1.0.0 — first F-Droid release"
   git push origin v1.0.0
   ```

6. [ ] Open fdroiddata MR (see below)
7. [ ] Respond to reviewer feedback
8. [ ] After merge, verify app on https://f-droid.org/packages/org.thediwan.diwanalmal/

## fdroiddata merge request

### Fork and branch

```bash
git clone https://gitlab.com/fdroid/fdroiddata.git
cd fdroiddata
git checkout -b add-diwanalmal
cp ../diwanalmal/fdroid/org.thediwan.diwanalmal.yml metadata/
```

### MR title

```
Add Diwan Al-Mal (org.thediwan.diwanalmal)
```

### MR description template

```markdown
## Summary

Add Diwan Al-Mal — offline-first personal finance manager (GPL-3.0-or-later).

- Source: https://github.com/thediwan/diwanalmal
- Flutter app with `.flutter` submodule pinned to 3.44.1
- F-Droid builds and signs (no upstream Binaries directive)

## Permissions

| Permission | Purpose |
|------------|---------|
| USE_BIOMETRIC / USE_FINGERPRINT | Optional local app unlock |
| POST_NOTIFICATIONS | Backup completion and monthly report reminders |
| RECEIVE_BOOT_COMPLETED | Reschedule WorkManager tasks after reboot |
| WAKE_LOCK | WorkManager background backup/report scheduling |

No INTERNET permission in release manifest. App is offline-first; no analytics or account server.

## External links

WhatsApp deep links (wa.me) open via ACTION_VIEW when user explicitly shares a debt message — user-initiated only.

## Build notes

- Requires `submodules: true` for `.flutter` at 3.44.1
- prebuild runs build_runner and gen-l10n
- Tested locally: fdroid build org.thediwan.diwanalmal (attach log)

## Store metadata

In-repo metadata at `metadata/en-US/` and `metadata/ar/` in source repository.
```

### Submit

```bash
fdroid lint org.thediwan.diwanalmal
git add metadata/org.thediwan.diwanalmal.yml
git commit -m "New App: Diwan Al-Mal (org.thediwan.diwanalmal)"
git push origin add-diwanalmal
```

Open MR on GitLab: https://gitlab.com/fdroid/fdroiddata/-/merge_requests/new

## Version bump workflow (each release)

1. Update `version:` in [pubspec.yaml](../pubspec.yaml) — increment **both** name and code:

   ```yaml
   version: 1.0.1+2   # versionName+versionCode
   ```

2. Update [CHANGELOG.md](../CHANGELOG.md)

3. Merge to `main`, then tag:

   ```bash
   git tag -a v1.0.1 -m "Release 1.0.1"
   git push origin v1.0.1
   ```

4. GitHub Actions `release.yml` creates release with test APKs

5. fdroiddata MR — add new build block and update current version:

   ```yaml
   Builds:
     - versionName: '1.0.1'
       versionCode: 2
       commit: v1.0.1
       # ... same prebuild/build steps ...

   CurrentVersion: '1.0.1'
   CurrentVersionCode: 2
   ```

6. Run `fdroid lint org.thediwan.diwanalmal` before pushing MR

## Rules

- **Never change** `applicationId` (`org.thediwan.diwanalmal`) after first listing
- **Never change** Flutter submodule major version without testing fdroid build
- Keep [docs/f-droid-publishing-plan.md](f-droid-publishing-plan.md) status updated
- Tag format: `vX.Y.Z` (matches `UpdateCheckMode: Tags`)

## Version mapping

| pubspec.yaml | Android | fdroiddata |
|--------------|---------|------------|
| `1.0.0+1` | versionName 1.0.0, versionCode 1 | CurrentVersion 1.0.0, CurrentVersionCode 1 |
| `1.0.1+2` | versionName 1.0.1, versionCode 2 | CurrentVersion 1.0.1, CurrentVersionCode 2 |

## Support links

- F-Droid Inclusion Policy: https://f-droid.org/docs/Inclusion_Policy/
- Flutter build template: https://gitlab.com/fdroid/fdroiddata/-/blob/master/templates/build-flutter.yml
- Issue tracker: https://github.com/thediwan/diwanalmal/issues
