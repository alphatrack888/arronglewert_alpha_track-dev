# Production readiness gate (Phase 0 + Phase 4)

Single entry point for **Android internal pilot** go/no-go against `https://api.alphatrack.app`.

**Related checklists (detail):**

- [PHASE_0_RELEASE_VERIFICATION.md](PHASE_0_RELEASE_VERIFICATION.md)
- [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md)
- [DEMO_MODE_AUDIT.md](DEMO_MODE_AUDIT.md) — if results look like demo/fake data

---

## Build metadata

| Field | Value |
|-------|-------|
| App version (`pubspec.yaml`) | 1.0.0+17 |
| Application ID | `com.marcgelwertz.alphatrack` |
| Git commit | _(fill: `git rev-parse HEAD`)_ |
| APK built | _(fill date/time)_ |
| Build command | `cd alpha_track_app && flutter build apk --release` |
| `DEMO_MODE` | **must be unset** for pilot gate |
| Device model / OS | |
| Tester (developer) | |
| Tester (client) | |
| Session date | |

**APK path (after build):** `build/app/outputs/flutter-apk/app-release.apk`

**Prerequisites:** `android/app/google-services.json` present locally; employee prod account; admin/second actor for push trigger tests; clean install or cleared app data for Step 1.

---

## Go / No-Go decision

| Decision | Selected |
|----------|----------|
| **Go** — internal Android pilot | [ ] |
| **Go with limits** (document below) | [ ] |
| **No-Go** (blockers below) | [ ] |

**Blockers / limits (if any):**

- 

---

## Step 1 — Build and install (Phase 0.1)

1. Build release APK (no `--dart-define=DEMO_MODE=true`).
2. Install on physical device; cold start with no saved session.

| Check | Expected | Result | Evidence |
|-------|----------|--------|----------|
| Cold start | Onboarding or login | | |
| No token | Cannot reach home without login | | |

---

## Step 2 — Production hosts (Phase 0.5)

During login and first home load (Logcat: filter paths / app logs; **no JWT** in logs).

| Check | Expected | Result | Evidence |
|-------|----------|--------|----------|
| REST | `api.alphatrack.app` | | |
| Socket | Production host (no accidental `SOCKET_URL` override) | | |
| Logs | No JWT substrings | | |

---

## Step 3 — Phase 0 functional smoke

| Screen / flow | Expected | Result | Evidence |
|---------------|----------|--------|----------|
| Login → home | Real projects | | |
| Project details → Notes | API notes or empty (not demo lawn copy) | | |
| Create note | API save; list refreshes | | |
| Profile | API-backed profile | | |
| Notifications list | API-backed (not demo inbox in release) | | |

---

## Step 4 — Phase 4.2 (push vs preferences)

Full table: [NOTIFICATION_MODULE_REGRESSION.md §4.2](NOTIFICATION_MODULE_REGRESSION.md#42--push-respects-pushenabled-and-categories)

| Step | Expected | Result | Evidence |
|------|----------|--------|----------|
| Login | Device register succeeds | | |
| Open preferences | GET matches UI after reopen | | |
| Push off + Save | No FCM on trigger; in-app OK | | |
| Push on + Save | FCM on trigger | | |
| Category off (e.g. project) | No push for that category | | |

---

## Step 5 — Phase 4.3 (regression matrix)

Full table: [NOTIFICATION_MODULE_REGRESSION.md §4.3](NOTIFICATION_MODULE_REGRESSION.md#43--regression-matrix)

| Area | Result | Notes |
|------|--------|-------|
| Auth | | |
| Timer / projects | | |
| Notes / leave / gallery / payroll | | |
| Notifications REST | | |
| Socket | | |
| Push | | |
| Preferences | | |

---

## Step 6 — Phase 4.4 client sign-off

**Statement:** The employee app (`com.marcgelwertz.alphatrack`) meets notification expectations for **internal Android pilot** rollout, including REST inbox, Socket.IO live updates, FCM push (Android), and `/notification-preferences`, subject to documented exclusions.

**Out of scope (accepted for this gate):**

- Deferred socket: `updatedProject::<authId>`, `note::<projectId>`
- iOS FCM until `GoogleService-Info.plist` for `com.marcgelwertz.alphatrack`
- Phase 5 (PDF reports, location trail) unless separately agreed
- Phase 6 (CI / Play internal track automation)

| Field | Value |
|-------|-------|
| Build version | 1.0.0+17 |
| Developer sign-off (name, date) | |
| Client sign-off (name, date) | |
| Approval reference (email/ticket) | |

---

## Automated pre-check (optional, before device session)

```bash
cd alpha_track_app
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Record output in build metadata or attach CI log when available.

---

## After gate passes

1. Check items **0.1**, **0.5**, **4.2**, **4.3**, **4.4** in [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md).
2. Add pilot line under Phase 0 exit: `Pilot approved YYYY-MM-DD, build 1.0.0+17`.
3. Proceed to **Phase 6** (mobile CI + internal Play upload) when ready.
