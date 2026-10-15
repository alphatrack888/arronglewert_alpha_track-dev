# P6 — Preferences & full regression session

**Target build:** Play **internal testing** **`v1.0.9+`** (re-fetch after PATCH on preferences save) or **`v1.0.8`** for baseline without P6.1.

**Git commit (v1.0.8):** `ccf4e4d`  
**API:** `https://api.alphatrack.app/api/v1`  
**Package:** `com.marcgelwertz.alphatrack`

Fill results into [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) and [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) Steps 4–6.

---

## Session metadata

| Field | Value |
|-------|-------|
| Device model / OS | _(fill)_ |
| App version | 1.0.0+17 (from Play) |
| Build tag | v1.0.8 / v1.0.9 |
| Tester (developer) | _(fill)_ |
| Tester (client) | _(fill)_ |
| Session date | _(fill)_ |
| Second actor (push triggers) | _(admin / colleague)_ |

---

## Static audit (2026-10-16)

| Check | Result | Notes |
|-------|--------|-------|
| **4.1** Preferences UI | Pass | Profile → Settings and Notifications menu → [`notification_preferences_screen`](lib/screens/notification_preferences_screen/notification_preferences_screen.dart); GET/PATCH via [`NotificationRepository`](lib/services/repository/notification_repository/notification_repository.dart) |
| Demo mode | Pass | `kDemoMode` blocks save with message |
| Logout / P1 | Pass | `deregisterCurrentToken` → `disconnectAndClear` → `storageClear` ([`profile_screen.dart`](lib/screens/profile_screen/profile_screen_main/profile_screen.dart)) |
| Categories | Pass | `leave`, `project`, `payroll`, `overtime`, `attendance`, `subscription` match backend categories |
| Server push policy | Pass (static) | [`notificationHelper.ts`](../time-tracker/src/helpers/notificationHelper.ts) skips FCM when `pushEnabled: false` or category off |
| Out of scope | Documented | Deferred socket `updatedProject` / `note::`; iOS FCM; profile `language_screen` local toggles not wired to API ([DEMO_MODE_AUDIT.md](DEMO_MODE_AUDIT.md)) |

**Pre-check (developer machine):**

```bash
cd alpha_track_app
python3 ci/p2_static_verify.py
flutter test
```

---

## Execution order (one login)

Use a **production employee** account with push permission granted unless testing deny paths.

| Step | Runbook | Focus |
|------|---------|--------|
| 1 | [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md) §1–3 | Auth, hosts, home/notes/profile/notifications smoke (if still pending) |
| 2 | [PHASE_P3_NOTIFICATIONS_REST.md](PHASE_P3_NOTIFICATIONS_REST.md) | REST inbox, pagination, mark read |
| 3 | [PHASE_P4_SOCKET_DEVICE.md](PHASE_P4_SOCKET_DEVICE.md) | Foreground `notification::` + project list refresh |
| 4 | [PHASE_P5_FCM_DEVICE.md](PHASE_P5_FCM_DEVICE.md) | Background/killed push, logout deregister |
| 5 | [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) **§4.2** | Push vs preferences (needs trigger account) |
| 6 | **§4.3** | Auth, timer, notes/leave/gallery/payroll smoke + copy notification rows from steps 2–5 |
| 7 | **§4.4** | Client sign-off statement |

### §4.2 reminders

- **Push off + Save** → trigger event → **no FCM** (in-app/socket OK).
- **Push on + Save** → FCM on trigger.
- **Project category off** → no push for project events; other categories unchanged.
- Cold start: reopen preferences → UI matches GET (verify after **v1.0.9** re-fetch on save).

**Evidence:** Screenshots or recording; Logcat — no JWT or FCM token paste.

---

## Sign-off checklist

- [ ] NOTIFICATION_MODULE_REGRESSION §4.2 complete
- [ ] NOTIFICATION_MODULE_REGRESSION §4.3 complete
- [ ] NOTIFICATION_MODULE_REGRESSION §4.4 signed
- [ ] PRODUCTION_READINESS_GATE Steps 4–6 filled
- [ ] Upgrade gate **Go with limits** → **Go** when Steps 1–3 also pass
