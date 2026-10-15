# P4 — Socket.IO device verification

**Build:** Play **internal testing** from tag **`v1.0.7+`** (includes app-resume socket reconnect).

**Account:** Production employee login. No `DEMO_MODE`.

Record results in [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) §4.3 **Socket** row.

---

## Automated audit (2026-10-16, pre-device)

| Check | Result | Notes |
|-------|--------|-------|
| Channel ID alignment | Pass (static) | JWT `authId` = User `_id`; app uses profile `data.id` for `notification::` / project channels |
| JWT handshake | Pass | `socket_service.dart` `setAuth({'token': accessToken})` |
| Login / splash connect | Pass | `auth_repository`, `splash_screen_controller` |
| Logout disconnect | Pass | `profile_screen` → `disconnectAndClear()` |
| Handler guards | Pass | `_registeredSocketUserId` / `_projectSocketUserId` prevent duplicate subscribe |
| Resume reconnect | Pass (code) | `main.dart` → `EmployeeSocketSubscriptions.onAppResumed()` |
| Payload parsing | Pass (static) | `Datum.fromJson` handles `_id`, nested `from`/`to` |
| Deferred | Documented | `updatedProject::<authId>`, `note::<projectId>` — REST / pull-to-refresh |

---

## Device checklist

| Step | Pass when | Result | Evidence |
|------|-----------|--------|----------|
| Login | Logcat: `Socket connected`; no immediate `Connect error` | Pending device | |
| Notifications foreground | Trigger backend notification → inbox updates without pull-to-refresh | Pending device | |
| Foreground dedupe | No duplicate snackbar when socket + push fire (same id) | Pending device | |
| Home projects | Assign/unassign project → list refreshes | Pending device | |
| Logout | Socket torn down; no events after logout | Pending device | |
| Resume | Background ~30s → foreground → `Socket connected` or reconnect log | Pending device | |

**Logcat:** filter `Socket` / `Received event` — do **not** paste JWTs.

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Developer | | |
| Client (optional) | | |
