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
| Release tag (P2 target) | **`v1.0.5`** on `main` (includes P0/P1; `v1.0.4` = `61eaadd` without them) |
| Application ID | `com.marcgelwertz.alphatrack` |
| Git commit | `99fd8d44030aeea134211910c67f6073662c6e9d` (`fix(P1): full session clear on logout`) |
| APK built | Mobile release workflow → Play **internal testing** (see tag `v1.0.5`) |
| Build command | `.github/workflows/mobile-release.yml` — `flutter build appbundle --release` (no dart-defines) |
| `DEMO_MODE` | **unset** (verified: `ci/p2_static_verify.py`) |
| Device model / OS | _(fill during [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md) session)_ |
| Tester (developer) | _(fill)_ |
| Tester (client) | _(fill)_ |
| Session date | _(fill)_ |

**Install:** Play internal or CI artifact — not local debug. Runbook: [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md).

**Automated pre-check (2026-10-16):** `python3 ci/p2_static_verify.py` pass; `flutter analyze` (15 infos/warnings, no errors); `flutter test` 13/13 pass; production host reachable (`https://api.alphatrack.app/` HTTP 200).

**Prerequisites:** `android/app/google-services.json` present locally; employee prod account; admin/second actor for push trigger tests; clean install or cleared app data for Step 1.

---

## Go / No-Go decision

| Decision | Selected |
|----------|----------|
| **Go** — internal Android pilot | [ ] |
| **Go with limits** (document below) | [x] |
| **No-Go** (blockers below) | [ ] |

**Blockers / limits (if any):**

- **P2 automated scope complete** (P2.1 static, P2.3 `DemoData` audit, CI pre-checks). **Steps 1–3 device evidence** still required per [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md) before upgrading to full **Go** for Phase 0 pilot.
- **Known limits (non-blockers):** onboarding “Continue as Guest” may bypass auth; Android backup may restore prefs on reinstall (P1.4).

---

## Step 1 — Build and install (Phase 0.1)

1. Build release APK (no `--dart-define=DEMO_MODE=true`).
2. Install on physical device; cold start with no saved session.

| Check | Expected | Result | Evidence |
|-------|----------|--------|----------|
| Cold start | Onboarding or login | Pending device | [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md) §Step 1 |
| No token | Cannot reach home without login | Pending device | Same |

---

## Step 2 — Production hosts (Phase 0.5)

During login and first home load (Logcat: filter paths / app logs; **no JWT** in logs).

| Check | Expected | Result | Evidence |
|-------|----------|--------|----------|
| REST | `api.alphatrack.app` | Pass (static + test traffic) | `ApiUrls.baseUrl`; widget tests hit `https://api.alphatrack.app/api/v1/...` |
| Socket | Production host (no accidental `SOCKET_URL` override) | Pass (static) | `socketUrl` default `liveDomain`; CI build has no `SOCKET_URL` define |
| Logs | No JWT substrings | Pending device | Confirm on login/home in Logcat |

---

## Step 3 — Phase 0 functional smoke

| Screen / flow | Expected | Result | Evidence |
|---------------|----------|--------|----------|
| Login → home | Real projects | Pending device | [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md) §Step 3 |
| Project details → Notes | API notes or empty (not demo lawn copy) | Pending device | P2.3: `loadProjectNotes` clears on API error when `!kDemoMode` |
| Create note | API save; list refreshes | Pending device | |
| Profile | API-backed profile | Pending device | |
| Notifications list | API-backed (not demo inbox in release) | Pending device | P2.3: all `DemoData` behind `kDemoMode` (audit 2026-10-16) |

---

## Step 4 — Phase 4.2 (push vs preferences)

Full table: [NOTIFICATION_MODULE_REGRESSION.md §4.2](NOTIFICATION_MODULE_REGRESSION.md#42--push-respects-pushenabled-and-categories)

| Step | Expected | Result | Evidence |
|------|----------|--------|----------|
| Login | Device register succeeds | Pending device | [PHASE_P6_REGRESSION_SESSION.md](PHASE_P6_REGRESSION_SESSION.md) |
| Open preferences | GET matches UI after reopen | Pending device | v1.0.9+ re-fetch after save |
| Push off + Save | No FCM on trigger; in-app OK | Pending device | §4.2 |
| Push on + Save | FCM on trigger | Pending device | |
| Category off (e.g. project) | No push for that category | Pending device | |

---

## Step 5 — Phase 4.3 (regression matrix)

Full table: [NOTIFICATION_MODULE_REGRESSION.md §4.3](NOTIFICATION_MODULE_REGRESSION.md#43--regression-matrix)

| Area | Result | Notes |
|------|--------|-------|
| Auth | Pending device | |
| Timer / projects | Pending device | |
| Notes / leave / gallery / payroll | Pending device | |
| Notifications REST | Pending device | [PHASE_P3_NOTIFICATIONS_REST.md](PHASE_P3_NOTIFICATIONS_REST.md) |
| Socket | Pending device | [PHASE_P4_SOCKET_DEVICE.md](PHASE_P4_SOCKET_DEVICE.md) |
| Push | Pending device | [PHASE_P5_FCM_DEVICE.md](PHASE_P5_FCM_DEVICE.md) |
| Preferences | Pending device | [PHASE_P6_REGRESSION_SESSION.md](PHASE_P6_REGRESSION_SESSION.md) §4.2 |

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
| Developer sign-off (name, date) | _(pending P6 session)_ |
| Client sign-off (name, date) | _(pending P6 session)_ |
| Approval reference (email/ticket) | _(pending §4.4)_ |

---

## Automated pre-check (optional, before device session)

```bash
cd alpha_track_app
python3 ci/p2_static_verify.py
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
