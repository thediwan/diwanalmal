# Auth Module

## Flow

```
New user:
  /auth/start → /auth/register → /auth/setup-lock → /auth/security-code → /onboarding → /

Returning (locked):
  /auth/splash → /auth/start or /auth/unlock → app

Forgot password:
  /auth/login → /auth/reset-password → /auth/login
```

## Routes

| Path | Screen | Notes |
|------|--------|--------|
| `/auth/splash` | Auth splash | Initial route |
| `/auth/start` | Start auth | Biometric entry when account exists |
| `/auth/register` | Register | Local account (Hive) |
| `/auth/login` | Login | Password; link to reset |
| `/auth/setup-lock` | Setup lock | 4-digit PIN + optional biometric |
| `/auth/security-code` | Security code | Shows recovery code; `extra` = code string |
| `/auth/unlock` | Unlock | PIN/biometric when session locked |
| `/auth/reset-password` | Reset password | Security code + new password |

## Redirect order (`app_router.dart`)

1. No account → `/auth/start`
2. No PIN → `/auth/setup-lock`
3. `needsSecurityCodeScreen` → `/auth/security-code`
4. `requiresUnlock` → `/auth/unlock` (also allows login, reset-password)
5. `!isSetupComplete` → `/onboarding`
6. Otherwise auth/onboarding paths → `/`

## Business rules

- **Security code**: 6 characters, generated after PIN setup, stored in Hive. Required for password reset (case-insensitive match).
- **PIN**: 4 digits, confirmed twice on setup.
- **Biometric**: Optional; uses `local_auth`.
- **Session lock**: On app `paused`/`detached` (not `inactive`, to avoid breaking biometric dialog).
- **Password**: Minimum 6 characters for register, login, and reset.

## Localization

All auth UI strings use `context.l10n` (see `lib/l10n/app_ar.arb`, `app_en.arb`). Extension: `lib/core/extensions/context_l10n.dart`.

## Services

- `AuthService`: register, `completeSecuritySetup`, `resetPassword`, credential validation
- `SettingsProvider`: session lock, `needsSecurityCodeScreen`, `displaySecurityCode`, routing state

## Testing checklist

- [ ] Register → PIN → security code visible → onboarding
- [ ] Kill app mid-flow; resume redirects correctly
- [ ] Lock app → unlock with PIN and biometric
- [ ] Reset password with saved security code
- [ ] Wrong security code shows error snackbar
- [ ] RTL layout on auth screens (Arabic)
