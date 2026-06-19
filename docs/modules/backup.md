# Backup Module

## Overview

Local daily backup of financial data and Hive settings as a single `.dmbackup` archive (zip) on device. One automatic copy is kept; each run replaces the previous file.

## Archive Contents

| File | Source |
|------|--------|
| `lazarus.db` | SQLite (transactions, wallets, goals, …) |
| `settings.hive` | App settings (PIN, theme, backup schedule, …) |
| `currencies.hive` | Legacy Hive currencies |
| `wallets.hive` | Legacy Hive wallets |
| `manifest.json` | Version metadata |

**Path:** `{documents}/backups/dewanalmal_backup.dmbackup`

## Business Rules

1. **Automatic backup** runs daily at user-configured time (default 02:00).
2. **Single retention:** previous archive is deleted before writing a new one.
3. **Notification** shown on successful automatic backup (WorkManager or app resume catch-up).
4. **Manual export** shares a timestamped copy via system share sheet.
5. **Manual import** replaces DB + Hive files after user confirmation; providers reload.
6. Archive contains **sensitive data** (PIN, password) — warn user not to share.

## Scheduling

- **Android:** `workmanager` one-off task rescheduled after each run.
- **All platforms:** catch-up on app startup/resume if today's slot passed and no backup today.
- **Boot:** WorkManager re-registers after device restart when app next opens.

## Key Files

- `lib/services/backup_service.dart`
- `lib/services/backup_scheduler_service.dart`
- `lib/services/backup_notification_service.dart`
- `lib/backup/backup_background.dart`
- `lib/features/settings/backup/backup_screen.dart`
- `lib/core/helpers/backup_schedule_helper.dart`

## Last Updated

2026-06-18 — Daily backup, export/import, notifications.
