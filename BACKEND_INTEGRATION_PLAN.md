# Backend integration & deployment readiness plan

**App:** `alpha_track_app/` (Figma 2026 redesign)  
**Backend:** `time-tracker/` → production `https://api.alphatrack.app/api/v1`  
**Reference implementation:** `../arronglewert_alpha_track-dev/` (push, device register, PDF reports)  
**Audit basis:** Static comparison of app vs `time-tracker` routes and notification pipeline (2026-10-13).

**How to use:** Complete phases in order. For each checklist item, record **Pass / Fail / N/A**, evidence (PR, screenshot, test log), and owner. Do not treat Play Store / internal track upload as “deployment ready” until **Phase 4 exit criteria** are met (minimum bar for notifications). **Phase 5–6** are product-dependent.

---

## Executive summary

| Phase | Focus | Blocks store? |
|-------|--------|----------------|
| **0** | Release hygiene & demo data | Yes (data integrity) |
| **1** | Notifications REST (read state, pagination) | Yes (inbox correctness) |
| **2** | Socket.IO (auth + event names) | No (foreground UX) |
| **3** | FCM push + device register | Yes (background alerts) |
| **4** | Notification preferences + logout cleanup | Yes (push policy parity) |
| **5** | Product gaps (PDF reports, location trail) | Per client decision |
| **6** | CI/CD, signing, store policy | Yes (shipping) |

---

## Phase 0 — Release hygiene & production safety

**Goal:** Release builds never show fake data or skip auth unintentionally.

### Checklist

- [ ] **0.1** Confirm `kDemoMode` is **off** in release builds without `--dart-define=DEMO_MODE=true` ([`lib/utils/demo_data/demo_data.dart`](lib/utils/demo_data/demo_data.dart)). _(Steps: [PHASE_0_RELEASE_VERIFICATION.md](PHASE_0_RELEASE_VERIFICATION.md).)_
- [x] **0.2** Remove or API-wire **Project Details → Notes** tab: stop initializing from `DemoData.projectNotes` ([`project_details_screen.dart`](lib/screens/home_screen/project_details/project_details_screen.dart)); use [`note_repository`](lib/services/repository/note_repository/note_repository.dart) like other note flows.
- [x] **0.3** Audit all `DemoData` / `kDemoMode` call sites; document any remaining release paths (grep `DemoData`, `kDemoMode`). _(See [DEMO_MODE_AUDIT.md](DEMO_MODE_AUDIT.md).)_
- [x] **0.4** Remove or gate debug-only token logging ([`api.dart`](lib/services/api/api.dart) — JWT substring removed; splash logs presence only).
- [ ] **0.5** Verify `ApiUrls.baseUrl` and `socketUrl` default to production (`liveDomain`) in release configuration ([`api_urls.dart`](lib/core/api_urls/api_urls.dart)). _(Source verified; device smoke in [PHASE_0_RELEASE_VERIFICATION.md](PHASE_0_RELEASE_VERIFICATION.md).)_

### Exit criteria

- Release APK (`flutter build apk --release`, no `DEMO_MODE`) requires login and shows **only API-backed** data on smoke-tested screens (home, profile, notifications list, project list).
- No `DemoData` surfaces on those screens when API returns errors (show error/empty, not fabricated payroll/gallery/notifications).
- **Sign-off:** Developer + client on one release build smoke test.

---

## Phase 1 — Notifications REST (inbox correctness)

**Goal:** Align with [`notifications.route.ts`](../time-tracker/src/app/modules/notifications/notifications.route.ts): list, mark read, pagination.

### Backend contract (reference)

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/notifications?page=&limit=` | Paginated inbox |
| `PATCH` | `/notifications/:id` | Mark one read |
| `PATCH` | `/notifications/all` | Mark all read |

### Checklist

- [ ] **1.1** Extend [`ApiUrls`](lib/core/api_urls/api_urls.dart): `notificationMarkReadBase`, `notificationMarkAllRead` (mirror legacy [`api_urls.dart`](../arronglewert_alpha_track-dev/lib/core/api_urls/api_urls.dart)).
- [ ] **1.2** Extend [`NotificationRepository`](lib/services/repository/notification_repository/notification_repository.dart): `fetchNotifications({page, limit})`, `markRead(id)`, `markAllRead()`.
- [ ] **1.3** Wire [`NotificationScreenController`](lib/screens/notification_screen/controller/notification_screen_controller.dart): pass `page`/`limit` on fetch and load-more; stop duplicating page 1 on scroll.
- [ ] **1.4** Wire [`notification_screen.dart`](lib/screens/notification_screen/notification_screen.dart) “mark read” actions to **PATCH**, not local-only `isRead = true`.
- [ ] **1.5** Manual test against production (or staging): mark one read → refresh → still read; mark all → all read.

### Exit criteria

- `GET /notifications?page=2` returns different rows than page 1 when inbox has enough items.
- Mark read persists after app restart (server is source of truth).
- **Evidence:** Screen recording or API logs for GET + PATCH.

---

## Phase 2 — Socket.IO (foreground real-time)

**Goal:** Connect with JWT and listen on **backend event names** ([`notificationHelper.ts`](../time-tracker/src/helpers/notificationHelper.ts), [`project.service.ts`](../time-tracker/src/app/modules/project/project.service.ts), [`note.service.ts`](../time-tracker/src/app/modules/note/note.service.ts)).

### Backend contract (reference)

| Requirement | Detail |
|-------------|--------|
| Auth | JWT in `handshake.auth.token`, `query.token`, or `Authorization` ([`socketAuth.ts`](../time-tracker/src/app/middleware/socketAuth.ts)) |
| Notification | `notification::<mongoUserId>` — `to` on notification document |
| New project | `newProject::<employeeId>` |
| Updated project | `updatedProject::<authId>` — **not** `updateProject::` |
| Removed project | `removedProject::<employeeId>` — **not** `removeProject::` |
| Note | `note::<projectId>` — **not** `note::<userId>` |

### Checklist

- [ ] **2.1** Update [`socket_service.dart`](lib/services/socket_service/socket_service.dart): `setAuth({'token': accessToken})` (or query token) using [`StorageServices.getAccessToken()`](lib/services/storage_services/storage_services.dart); reconnect on token refresh/login.
- [ ] **2.2** Confirm `socketUrl` host matches API (default `liveDomain`); document `SOCKET_URL` dart-define for local backend.
- [ ] **2.3** Fix event subscriptions in [`notification_screen_controller.dart`](lib/screens/notification_screen/controller/notification_screen_controller.dart):
  - `updatedProject::$authId` — resolve whether app stores **user profile id** vs **authId**; align with JWT payload and `setUserId` usage.
  - `removedProject::$userId`
  - `note::$projectId` — subscribe per active project or global note handler keyed by project membership.
- [ ] **2.4** Initialize socket after login (or on app resume with valid token), disconnect on logout.
- [ ] **2.5** Manual test: with app open on Notifications, trigger backend notification → list updates without pull-to-refresh.

### Exit criteria

- Server logs show authenticated socket connection (no immediate disconnect).
- At least **`notification::<userId>`** updates UI in foreground when backend sends notification.
- Project/note events either **work** or are **explicitly deferred** in sign-off with UX fallback (pull-to-refresh only).
- **Evidence:** Client logs “Socket connected” + received event payload; optional server log snippet.

### Phase 2 deferrals (employee app)

| Event | Status |
|-------|--------|
| `updatedProject::<authId>` | Deferred — emitted to company admin `authId`, not employee Mongo id |
| `note::<projectId>` | Deferred — requires per-project subscriptions; notes via REST / pull-to-refresh |
| `newProject` / `removedProject` | Implemented on home — refreshes project list |

---

## Phase 3 — FCM push & device registration

**Goal:** Port legacy push so background/killed delivery matches [`notificationHelper`](../time-tracker/src/helpers/notificationHelper.ts) push fan-out.

### Backend contract (reference)

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/devices/register` | `{ token, platform }` |
| `DELETE` | `/devices/:token` | Deregister on logout |
| — | FCM | Server sends push when preferences allow |

### Checklist

- [ ] **3.1** Add Firebase to app: `firebase_core`, `firebase_messaging`; Android `google-services` plugin; iOS `GoogleService-Info.plist` for **`com.marcgelwertz.alphatrack`**.
- [ ] **3.2** Port [`PushNotificationService`](../arronglewert_alpha_track-dev/lib/services/push_notification_service/push_notification_service.dart) + routing/dedupe as needed ([`notification_routing`](../arronglewert_alpha_track-dev/lib/utils/notification_routing/)).
- [ ] **3.3** Call `initialize()` from [`main.dart`](lib/main.dart); `registerCurrentToken()` after login; deregister on logout ([`profile_screen`](lib/screens/profile_screen/profile_screen_main/profile_screen.dart)).
- [ ] **3.4** Add `POST_NOTIFICATIONS` to Android manifest when targeting current SDK.
- [ ] **3.5** Manual test: login → register device → send test notification from backend/admin → push received on device **with app killed**.

### Exit criteria

- `POST /devices/register` succeeds (201/200) with real FCM token after login.
- Push notification appears on lock screen when app is backgrounded/killed.
- Logout removes token from server (`DELETE /devices/:token`) or documented equivalent.
- **Evidence:** Play internal or TestFlight build + one captured push delivery.

### Phase 3 platform notes

| Platform | Status |
|----------|--------|
| Android | `google-services.json` for `com.marcgelwertz.alphatrack` — see `android/app/FIREBASE_SETUP.md` |
| iOS | Deferred until `GoogleService-Info.plist` for `com.marcgelwertz.alphatrack` — see `ios/Runner/FIREBASE_SETUP.md` |

---

## Phase 4 — Notification preferences & parity sign-off

**Goal:** Match backend [`/notification-preferences`](../time-tracker/src/routes/index.ts) and legacy behavior where required.

### Checklist

- [x] **4.1** Add `ApiUrls.notificationPreferences`; port preferences screen from legacy if product requires push category toggles.
- [ ] **4.2** Verify server push skip when `pushEnabled: false` — UI reflects server state after fetch. _(Run steps in [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md).)_
- [ ] **4.3** Regression matrix: login, timer, projects, notes, leave, gallery, payroll, notifications (REST + socket + push). _(Template: [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md).)_
- [ ] **4.4** Client sign-off: “Employee app meets notification expectations for internal/production rollout.” _(Template in same doc.)_

### Exit criteria

- Push respects user preferences when disabled on server.
- Regression matrix **Pass** on Android release build against `https://api.alphatrack.app`.
- Written sign-off (client) for **notification module** scope.

---

## Phase 5 — Product-dependent backend features (optional)

**Goal:** Close gaps only if the client requires parity with legacy or dashboards.

### 5.A PDF reports

| Legacy | New app | Backend |
|--------|---------|---------|
| PDF download | Analytics UI only | `GET /timetracker/reports/monthly`, `attendance`, async jobs |

- [ ] **5.A.1** Client decision: **analytics only** vs **restore PDF** vs both.
- [ ] **5.A.2** If PDF: add URLs + port `reports_screen` / download flow from legacy.

**Exit criteria:** Documented product decision; if PDF required, download works for employee role on production API.

### 5.B Periodic location trail

| Backend | App today |
|---------|-----------|
| `POST /timetracker/location` | Not called; GPS only on timer events |

- [ ] **5.B.1** Client decision: clock-event GPS only vs background trail.
- [ ] **5.B.2** If trail: implement periodic POST + Play FGS policy (separate from this doc).

**Exit criteria:** Documented decision; if trail required, API receives periodic points during active session.

### 5.C Self-service registration

- Backend: `POST /auth/signup` (admin/company only), not `/auth/register`.
- App: signup disabled — **acceptable** if employees are provisioned by admin.

**Exit criteria:** **N/A** or signup wired to correct endpoint if product changes.

---

## Phase 6 — Ship pipeline (CI/CD & stores)

**Goal:** Repeatable signed builds from monorepo; not blocked by integration debt above.

**Priority:** **Android** CI/CD and **Play internal** upload first (same as legacy). **iOS / TestFlight** is explicitly **later** — see migration doc **M7**, not a Phase 6 exit requirement.

Align with workspace [`MOBILE_RELEASE_PLAN.md`](../MOBILE_RELEASE_PLAN.md) and port CI from `arronglewert_alpha_track-dev`. **Option A (redesign as GitHub repo root):** [MOBILE_REPO_MIGRATION_OPTION_A.md](MOBILE_REPO_MIGRATION_OPTION_A.md).

### Checklist

- [ ] **6.1** Port GitHub Actions + `ci/` + Fastlane to app repo (Android path required; iOS IDs updated when M7 starts).
- [ ] **6.2** **Android** secrets on target GitHub repo; green `mobile-ci` on PR.
- [ ] **6.3** Signed **AAB** from CI; **Play internal** upload (platform `android` on Mobile release).
- [ ] **6.4** Play FGS / location declaration; data safety; reviewer credentials.

### Exit criteria

- One successful **Play internal** upload from CI for **Android** (not only local APK). IPA/TestFlight is **out of scope** until migration **M7**.
- Phases **0–4** exit criteria met for scope agreed with client.

---

## Decision matrix (track per finding)

| ID | Finding | Phase | Severity | Status |
|----|---------|-------|----------|--------|
| B-01 | DemoData / project notes in release | 0 | High | Fixed (API notes + create) |
| B-02 | Notification PATCH not called | 1 | High | |
| B-03 | Notification pagination broken | 1 | Medium | |
| B-04 | Socket no JWT | 2 | High | |
| B-05 | Socket wrong event names | 2 | High | |
| B-06 | No FCM / devices/register | 3 | High | |
| B-07 | No notification preferences | 4 | Medium | |
| B-08 | No PDF reports in redesign | 5.A | Medium | |
| B-09 | No periodic location API | 5.B | Low | |
| B-10 | CI/CD not on monorepo | 6 | High | |

---

## Suggested order of execution

```text
Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → (Phase 5 if needed) → Phase 6
```

**Minimum for “notifications acceptable”:** Phases **0, 1, 3, 4** (Phase **2** strongly recommended for foreground UX).  
**Minimum for “employee app internal test”:** Phase **0** + smoke on core REST (timer/projects) without full push.

---

## References

| Resource | Path |
|----------|------|
| Backend routes | [`time-tracker/src/routes/index.ts`](../time-tracker/src/routes/index.ts) |
| Socket auth | [`time-tracker/src/app/middleware/socketAuth.ts`](../time-tracker/src/app/middleware/socketAuth.ts) |
| Push orchestration | [`time-tracker/src/helpers/notificationHelper.ts`](../time-tracker/src/helpers/notificationHelper.ts) |
| Legacy mobile API + push | [`arronglewert_alpha_track-dev/lib/`](../arronglewert_alpha_track-dev/lib/) |
| App API URLs | [`lib/core/api_urls/api_urls.dart`](lib/core/api_urls/api_urls.dart) |

---

*Update checklist statuses in this file as work completes.*
