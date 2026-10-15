# Notification module regression matrix (Phase 4)

**Master gate:** [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) (Steps 4–6).

Target environment: **Android release or profile** build against `https://api.alphatrack.app/api/v1`.

Record **Pass / Fail / N/A**, device model, app version (`pubspec.yaml`), tester name, and date for each row.

## 4.2 — Push respects `pushEnabled` and categories

| Step | Expected | Result | Evidence |
|------|----------|--------|----------|
| Login | Device register succeeds (Phase 3) | | |
| Open Notification preferences | GET loads; UI matches server after cold start | | |
| Turn push **off**, Save | PATCH 200; reopen → `pushEnabled` false | | |
| Trigger push-eligible event | No FCM; in-app/socket may still update | | |
| Turn push **on**, Save | FCM arrives when event fires | | |
| Disable one category (e.g. project), Save | No push for that category; others unchanged | | |

## 4.3 — Regression matrix

| Area | Checks | Result | Notes |
|------|--------|--------|-------|
| Auth | Login, logout (deregister before clear), splash restore | | |
| Timer / projects | Start/pause/stop; list refresh on `newProject::` / `removedProject::` | | |
| Notes / leave / gallery / payroll | Smoke: primary flows unchanged | | |
| Notifications REST | List, pagination, mark one/all read | Pending device | Automated: `notification_inbox_pagination_test.dart` (2026-10-16). Manual: [PHASE_P3_NOTIFICATIONS_REST.md](PHASE_P3_NOTIFICATIONS_REST.md); target **`v1.0.6+`** |
| Socket | Live inbox insert; snackbar dedupe with push | Pending device | Code: resume reconnect + `socket_channel_names_test.dart` (2026-10-16). Manual: [PHASE_P4_SOCKET_DEVICE.md](PHASE_P4_SOCKET_DEVICE.md); **`v1.0.7+`** |
| Push | Foreground, background, killed-state tap routing | | |
| Preferences | GET/PATCH, push off/on, category toggle | | |

## 4.4 — Client sign-off

**Statement:** The employee app (`com.marcgelwertz.alphatrack`) meets notification expectations for internal/production rollout, including REST inbox, Socket.IO live updates, FCM push (Android), and `/notification-preferences`.

**Out of scope (documented):**

- Deferred socket channels: `updatedProject::<authId>`, `note::<projectId>`
- iOS FCM until `GoogleService-Info.plist` for `com.marcgelwertz.alphatrack`
- Phase 5 (PDF reports, location trail) and Phase 6 (CI/store pipeline) unless separately agreed

| Field | Value |
|-------|-------|
| Build version | 1.0.0+17 (update if bumped) |
| Signatory | |
| Date | |
| Signature / approval reference | |
