# C1 — Auth / login triage matrix

Use this when investigating “login sometimes fails” or unexpected logout. Map the report to a **bucket** before changing code.

**Related:** [CLIENT_ISSUES_PHASED_FIX_PLAN.md](CLIENT_ISSUES_PHASED_FIX_PLAN.md) Phase 5, [BUGFIX_PHASED_PLAN.md](BUGFIX_PHASED_PLAN.md) Phase 1.

| Bucket | How to simulate | Typical HTTP / app signal | Expected UX (post Phase 5) |
|--------|-----------------|---------------------------|----------------------------|
| Bad credentials | Wrong password on login | 4xx + error message snackbar | Stay on login; no home |
| OTP required | Account needs verification | **407** + `success: true` in body | OTP screen ([`auth_repository.dart`](lib/services/repository/auth_repository/auth_repository.dart)) |
| Expired access, valid refresh | Login → clear/corrupt **access** token only → API action | First call **401** → refresh → retry succeeds | User stays in app; no login screen |
| Invalid / expired refresh | Clear refresh token or revoke server-side | **401** after failed refresh | Login screen (not onboarding if onboard complete) |
| Guest (no token) | Continue as guest from onboarding | APIs: empty / errors; logs “no token” | No refresh attempt; data requires login |
| Offline | Airplane mode | `SocketException` / timeout | `checkInternetTitle` snackbar; session kept |
| Backend refresh JWT bug | After refresh, APIs still 401 | Refresh **200** but scoped APIs fail | Escalate backend ([`BACKEND_BUG_AUDIT.md`](../time-tracker/BACKEND_BUG_AUDIT.md) `authId`); document in QA notes |

## Manual smoke log (fill per release)

| Date | Tester | Scenario | Status code | User-visible message | Pass? |
|------|--------|----------|-------------|----------------------|-------|
| | | Expired access + refresh | | | |
| | | Expired refresh | | | |
| | | OTP 407 | | | |
| | | Guest home API | | | |

## Refresh API contract

- **POST** `https://api.alphatrack.app/api/v1/auth/refresh-token`
- Body: `{ "refreshToken": "<stored refresh>" }`
- Success: `data.accessToken` (refresh token rotation not required by current backend)
