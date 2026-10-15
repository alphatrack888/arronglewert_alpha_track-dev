# Production phased plan (no new features)

**App:** `alpha_track_app/` → GitHub `alphatrack888/arronglewert_alpha_track-dev`  
**Goal:** Release builds require real login, show API-backed data, logout and reinstall behave correctly, then meet backend parity for internal pilot on `https://api.alphatrack.app`.

**Related docs (detail lives there):**

| Doc | Use for |
|-----|---------|
| [DEMO_MODE_AUDIT.md](DEMO_MODE_AUDIT.md) | Every `kDemoMode` / `DemoData` call site |
| [PHASE_0_RELEASE_VERIFICATION.md](PHASE_0_RELEASE_VERIFICATION.md) | Build commands + Phase 0 smoke table |
| [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) | Go/No-Go sign-off on one release build |
| [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md) | Notifications, socket, FCM, preferences (Phases 1–4) |
| [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) | Push + preferences regression |
| [MOBILE_CI_CD.md](MOBILE_CI_CD.md) | CI release, secrets, tags |
| [MOBILE_REPO_MIGRATION_OPTION_A.md](MOBILE_REPO_MIGRATION_OPTION_A.md) | Publish `alpha_track_app` → GitHub |

**Out of scope:** New product features, iOS TestFlight (until Android pilot is done), PDF reports / location trail unless client reopens Phase 5 in the integration plan.

---

## Summary

| Phase | Name | Blocks pilot? |
|-------|------|----------------|
| **P0** | Demo mode & release hygiene | **Yes** |
| **P1** | Logout & session storage | **Yes** |
| **P2** | Production build smoke (API hosts + core screens) | **Yes** |
| **P3** | Notifications REST | **Yes** (inbox correctness) |
| **P4** | Socket.IO (foreground) | No (UX) |
| **P5** | FCM + device register | **Yes** (background push) |
| **P6** | Preferences + full regression sign-off | **Yes** (push policy) |
| **P7** | Store pilot & ongoing release | Ops |

Complete **P0 → P2** before calling the app “production installable.” Add **P3–P6** for notification-complete internal rollout. **P7** is Play internal + CI tags you already have wired.

---

## P0 — Demo mode & release hygiene

**Problem:** Debug and optional `DEMO_MODE` release builds skip login and show **Marc G. / `marc@demo.co`** and fake projects. Logout appears broken because splash always re-enters the app in demo.

**Root cause:** [`lib/utils/demo_data/demo_data.dart`](lib/utils/demo_data/demo_data.dart) — `kDemoMode = DEMO_MODE dart-define OR (debug AND _demoReviewEnabled)`.

### Tasks

- [x] **P0.1** Set `_demoReviewEnabled = false` so **debug** defaults to real auth (optional: `flutter run --dart-define=DEMO_MODE=true` only when reviewing UI without backend).
- [x] **P0.2** Confirm **CI / Play builds** never pass `--dart-define=DEMO_MODE=true` (`.github/workflows` — already absent; comment added on release build step).
- [x] **P0.3** Document for the team: **do not** pilot-test with `flutter run` or debug APK; use **release** APK/AAB from CI or `flutter build apk --release` without `DEMO_MODE`.
- [x] **P0.4** Visible **“DEMO”** banner when `kDemoMode` is true ([`lib/widgets/demo_mode_banner.dart`](lib/widgets/demo_mode_banner.dart)).
- [ ] **P0.5** (Optional, larger) Remove `DemoData` and all `kDemoMode` branches — deferred.

**P0 code sign-off:** 2026-10-15 — `_demoReviewEnabled=false`, banner wired in `main.dart`. Device §0.1 release smoke: _pending tester_.

### Verify (release APK, clean install)

```bash
cd alpha_track_app
flutter build apk --release
# Do NOT pass --dart-define=DEMO_MODE=true
```

| Check | Expected |
|-------|----------|
| Cold start | Onboarding or login |
| No credentials | Cannot reach home |
| Profile | Not `marc@demo.co` unless that is a real API user |

### Exit criteria

- Release without `DEMO_MODE` never sets `kDemoMode` true.
- [PHASE_0_RELEASE_VERIFICATION.md](PHASE_0_RELEASE_VERIFICATION.md) §0.1 table signed off.

---

## P1 — Logout & session storage

**Problem:** With demo off, logout should fully end the session. Today `storageClear()` only clears access token, language reset, and location — not refresh token, user id, etc.

### Tasks

- [x] **P1.1** `clearSession()` wipes auth keys in [`AppStorageKey`](lib/core/constant/app_storage_key.dart); `storageClear()` delegates to it.
- [x] **P1.2** **Language preserved** on logout (removed forced reset to english).
- [x] **P1.3** Splash: no token + onboard complete → **login**; else onboarding. `setOnboardScreen` on final onboarding + successful login.
- [x] **P1.4** Documented: `allowBackup=true` may restore prefs on reinstall; verify logout on same install first.

**P1 code sign-off:** 2026-10-16 — profile cleared in memory on logout. Device smoke: _pending tester_.

### Verify

| Check | Expected |
|-------|----------|
| Login → logout | Login/onboarding screen |
| Kill app → reopen | Still logged out |
| Reinstall (no backup) | Login required |

### Exit criteria

- Logout + cold start never auto-enters home without a new login (release build, real account).

---

## P2 — Production API smoke (Phase 0.5 + gate Steps 1–3)

**Goal:** One release build on a physical device against production hosts with a **real** employee account.

### Tasks

- [x] **P2.1** Confirm [`ApiUrls`](lib/core/api_urls/api_urls.dart): `baseUrl` → `https://api.alphatrack.app/api/v1`, socket default → production (no accidental `SOCKET_URL` override in release). _(2026-10-16: `ci/p2_static_verify.py`; commit `99fd8d4`.)_
- [x] **P2.2** Run [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) Steps 1–3: build metadata, install, login → home, project notes, create note, profile, notifications list. _(Metadata + **Go with limits**; device Steps 1/3 pending — [PHASE_P2_DEVICE_GATE.md](PHASE_P2_DEVICE_GATE.md); target Play build **`v1.0.5`**.)_
- [x] **P2.3** Confirm API failures show **error/empty**, not demo payroll/gallery/notifications (grep `DemoData` usage without `kDemoMode` guard). _(2026-10-16: [DEMO_MODE_AUDIT.md](DEMO_MODE_AUDIT.md) P2.3 note.)_

### Exit criteria

- Developer + client sign-off row in **PRODUCTION_READINESS_GATE** (Go or Go with limits).
- Maps to **BACKEND_INTEGRATION_PLAN** Phase **0** exit criteria.

---

## P3 — Notifications REST (integration Phase 1)

**Goal:** Inbox matches server: pagination, mark read persists.

### Tasks

Follow checklist **1.1–1.5** in [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md):

- [ ] API URLs for mark read / mark all read
- [ ] Repository + controller pagination and PATCH wiring
- [ ] UI mark-read calls server, not local-only

### Exit criteria

- Page 2 ≠ page 1 when enough items; mark read survives app restart.

---

## P4 — Socket.IO (integration Phase 2)

**Goal:** Foreground real-time updates with JWT and correct event names.

### Tasks

Follow **Phase 2** in [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md).

### Exit criteria

- Socket connects after login; known events update UI without full refresh.

**Note:** Does not block “app works without push,” but improves live UX.

---

## P5 — FCM & device registration (integration Phase 3)

**Goal:** Background/killed push; register on login, deregister on logout.

### Tasks

- [ ] Firebase `google-services.json` for `com.marcgelwertz.alphatrack` (local + `ANDROID_GOOGLE_SERVICES_JSON_BASE64` on CI)
- [ ] Follow **3.1–3.5** in integration plan
- [ ] Logout calls deregister (already wired from profile; verify after P1 storage clear)

### Exit criteria

- `POST /devices/register` after login; push on lock screen with app killed; logout removes device server-side.

---

## P6 — Preferences & regression (integration Phase 4)

**Goal:** Push policy parity with backend; full employee regression.

### Tasks

- [ ] Run [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md)
- [ ] **4.2–4.4** in integration plan (preferences + client sign-off)

### Exit criteria

- Client sign-off: employee app meets notification expectations for internal/production rollout.

---

## P7 — Store pilot & ongoing release (integration Phase 6 + migration done)

**Goal:** Repeatable Android internal track via CI; workspace publish flow.

### Already done (migration)

- GitHub `main` = redesign at root; Mobile CI green; `legacy/final` tag.

### Tasks

- [ ] Verify GitHub secrets + `mobile-release` environment ([`.env.example`](.env.example))
- [ ] **Mobile release** with upload **off** → download signed AAB artifact (smoke)
- [ ] **Mobile release** or tag `v*.*.*` with upload **on** → Play internal (only after P0–P2 minimum, ideally P3–P6 for push)
- [ ] Ongoing: edit `alpha_track_app/` → rsync to `arronglewert_alpha_track-dev/` (no `rsync --delete` on clone) → push `main`

### Exit criteria

- One successful internal track build from CI; testers install from Play.

---

## Suggested timeline

| When | Phases |
|------|--------|
| **Immediately** | P0, P1 (code + one release APK test) |
| **Same sprint** | P2 gate sign-off |
| **Before push-heavy pilot** | P3 → P6 |
| **When QA approves** | P7 Play internal |

---

## Decision: keep or delete demo code?

| Approach | Effort | When |
|----------|--------|------|
| **Keep demo, default off** (P0.1–P0.3) | Low | **Recommended** for production now |
| **Keep demo, `DEMO_MODE` only** | Low | Apple/reviewer builds without backend |
| **Delete demo entirely** | Medium–high | No reviewer builds; simplify codebase |

---

## Tracking

Update this file with **Pass / date / build** per phase. Link PRs next to tasks. For notification detail, prefer checkboxes in **BACKEND_INTEGRATION_PLAN** and evidence in **PRODUCTION_READINESS_GATE**.
