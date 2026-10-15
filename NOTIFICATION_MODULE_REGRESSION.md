# Notification module regression matrix (Phase 4)

**Master gate:** [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) (Steps 4–6).

Target environment: **Android release or profile** build against `https://api.alphatrack.app/api/v1`.

Record **Pass / Fail / N/A**, device model, app version (`pubspec.yaml`), tester name, and date for each row.

## 4.2 — Push respects `pushEnabled` and categories

| Step | Expected | Result | Evidence |
|------|----------|--------|----------|
| Login | Device register succeeds (Phase 3) | Pending device | [PHASE_P5_FCM_DEVICE.md](PHASE_P5_FCM_DEVICE.md); **v1.0.8+** |
| Open Notification preferences | GET loads; UI matches server after cold start | Pending device | Static 4.1 pass; session [PHASE_P6_REGRESSION_SESSION.md](PHASE_P6_REGRESSION_SESSION.md) |
| Turn push **off**, Save | PATCH 200; reopen → `pushEnabled` false | Pending device | v1.0.9+ re-fetches after save |
| Trigger push-eligible event | No FCM; in-app/socket may still update | Pending device | Requires second actor |
| Turn push **on**, Save | FCM arrives when event fires | Pending device | |
| Disable one category (e.g. project), Save | No push for that category; others unchanged | Pending device | |

## 4.3 — Regression matrix

| Area | Checks | Result | Notes |
|------|--------|--------|-------|
| Auth | Login, logout (deregister before clear), splash restore | Pending device | P1/P5 logout order verified static |
| Timer / projects | Start/pause/stop; list refresh on `newProject::` / `removedProject::` | Pending device | |
| Notes / leave / gallery / payroll | Smoke: primary flows unchanged | Pending device | |
| Notifications REST | List, pagination, mark one/all read | Pending device | Automated: `notification_inbox_pagination_test.dart` (2026-10-16). Manual: [PHASE_P3_NOTIFICATIONS_REST.md](PHASE_P3_NOTIFICATIONS_REST.md); target **`v1.0.6+`** |
| Socket | Live inbox insert; snackbar dedupe with push | Pending device | Code: resume reconnect + `socket_channel_names_test.dart` (2026-10-16). Manual: [PHASE_P4_SOCKET_DEVICE.md](PHASE_P4_SOCKET_DEVICE.md); **`v1.0.7+`** |
| Push | Foreground, background, killed-state tap routing | Pending device | `device_register_url_test.dart` (2026-10-16). Manual: [PHASE_P5_FCM_DEVICE.md](PHASE_P5_FCM_DEVICE.md); **`v1.0.8+`** |
| Preferences | GET/PATCH, push off/on, category toggle | Pending device | §4.2 + [PHASE_P6_REGRESSION_SESSION.md](PHASE_P6_REGRESSION_SESSION.md); **v1.0.9+** for post-save re-fetch |

## 4.4 — Client sign-off

**Statement:** The employee app (`com.marcgelwertz.alphatrack`) meets notification expectations for internal/production rollout, including REST inbox, Socket.IO live updates, FCM push (Android), and `/notification-preferences`.

**Out of scope (documented):**

- Deferred socket channels: `updatedProject::<authId>`, `note::<projectId>`
- iOS FCM until `GoogleService-Info.plist` for `com.marcgelwertz.alphatrack`
- Phase 5 (PDF reports, location trail) and Phase 6 (CI/store pipeline) unless separately agreed

| Field | Value |
|-------|-------|
| Build version | 1.0.0+17 (Play internal **v1.0.8** / **v1.0.9**) |
| Signatory | _(pending client)_ |
| Date | _(fill after session)_ |
| Signature / approval reference | _(fill after §4.2–4.3 pass)_ |
