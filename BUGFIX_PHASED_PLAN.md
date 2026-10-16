# Bugfix phased plan (post-audit, no new features)

**App:** `alpha_track_app/`  
**Backend:** `https://api.alphatrack.app/api/v1` (`time-tracker/`)  
**Source:** Static backend↔app audit (2026-10-16). Fixes only — not an expansion of [PRODUCTION_PHASED_PLAN.md](PRODUCTION_PHASED_PLAN.md) or [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md).

**Out of scope here:** Full device regression matrices, new APIs, PDF/location, socket note channels, delete-account backend (no route wired yet), iOS pilot.

---

## Summary

| Phase | Focus | Why one phase |
|-------|--------|----------------|
| **1** | Auth & session integrity | Guest bypass, 401 routing, and refresh-token storage are all “who is logged in and what happens when session dies.” |
| **2** | Company context, leave API, preferences UX | Wrong `companyId` and fake toggles both break trust in settings/leave without touching auth plumbing. |

Complete **Phase 1** before the next Play internal tag. **Phase 2** can ship in the same release if time allows; it does not depend on backend changes.

---

## Phase 1 — Auth & session integrity

**Problems**

1. **Continue as Guest** on onboarding navigates to main app with **no token** — APIs fail or show empty; same class of issue as old demo bypass ([`onboarding_screen_final.dart`](lib/screens/onboarding_screen/onboarding_screen.dart)).
2. **401** handling in [`api_services.dart`](lib/services/api/api_services.dart) clears session then opens **onboarding**, even when onboard is already complete — confusing vs splash → login ([`splash_screen_controller.dart`](lib/screens/splash_screen/controller/splash_screen_controller.dart)).
3. **Refresh token** saved incorrectly on login: `data["accessToken"]` is stored as refresh ([`auth_repository.dart`](lib/services/repository/auth_repository/auth_repository.dart)); backend sends `refreshToken` separately ([`time-tracker` auth responses](https://github.com/alphatrack888/time-tracker)).

**Tasks**

- [x] **1.1 Guest:** _(2026-10-16: restored per client — “Continue as Guest” on onboarding in all builds; UI-only preview without token. Compile-time demo: `--dart-define=DEMO_MODE=true`.)_
- [x] **1.2 401:** Centralize post-401 navigation: after `clearSession()` / `storageClear()`, route to **login** when `getOnboardScreen()` is true, else onboarding. Align [`api.dart`](lib/services/api/api.dart) interceptor with the same rule (today it clears but does not navigate).
- [x] **1.3 Refresh token:** Persist `data["refreshToken"]` when present; fall back to empty if absent. No refresh interceptor required in this phase unless you already use `getRefreshToken()`.

**Exit criteria**

- Release build: onboarding offers login/signup only; no path to home without token.
- Expired/invalid token (simulate 401): user lands on **login**, not onboarding carousel.
- Login response stores distinct access + refresh values when backend sends both.

**Smoke (manual, ~10 min)**

- Fresh install → complete onboard → confirm no guest → login → home.
- Revoke session server-side or use bad token → next API call → login screen, profile not stale demo user.

---

## Phase 2 — Company context, leave API, preferences UX

**Problems**

1. **`companyId`** is only set when the **home** project list loads ([`home_screen_controller.dart`](lib/screens/home_screen/main_home/controller/home_screen_controller.dart)). [`leave_management_repository.dart`](lib/services/repository/leave_management_repository/leave_management_repository.dart) calls `GET /leavebalance/company/{id}` with an **empty** id → **400** if Break/Leave opens before home finishes or user has no projects.
2. **Profile** already includes `data.company.id` ([`profile_model.dart`](lib/screens/profile_screen/profile_screen_main/models/profile_model.dart)) but [`profile_controller.dart`](lib/screens/profile_screen/profile_screen_main/controller/profile_controller.dart) does not persist it to storage (unlike `userId`).
3. **Account → Preferences** ([`language_screen.dart`](lib/screens/profile_screen/language_screen/language_screen.dart)) shows **local-only** notification toggles. Real prefs live under **Settings → Notification preferences** ([`notification_preferences_screen.dart`](lib/screens/notification_preferences_screen/notification_preferences_screen.dart)) and `/notification-preferences`.

**Tasks**

- [x] **2.1 Company from profile:** After successful `fetchProfile` / login profile prime, `setCompanyId(profile.data?.company?.id)` when non-empty (do not overwrite a valid id with empty).
- [x] **2.2 Leave fetch guard:** In `fetchAlltheLeaveBalance()` (and break controller if needed), if `getCompanyId()` is empty, skip the request and leave UI empty/loading until id is available; mirror the guard already used in [`leave_screen_controller.dart`](lib/screens/break_screen/leave_screen/controller/leave_screen_controller.dart) for apply-leave.
- [x] **2.3 Preferences screen:** Remove dummy notification toggles from `LanguageScreen` **or** replace with a single row “Notification preferences” → `AppRoute.notificationPreferencesScreen`. Language/theme behavior unchanged.

**Exit criteria**

- After login, opening Break/Leave does not hit `/leavebalance/company/` with a trailing empty segment before profile/home has run.
- Employee with projects: leave balance loads when `companyId` is known from profile or first project.
- Preferences screen no longer implies server-side push settings changed when only local state toggled.

**Smoke (manual, ~10 min)**

- Login → immediately open Break (before dwelling on Home) → no 400 in logs; balance appears when company id exists.
- Account → Preferences: only real language/theme (+ link to notification prefs if applicable).
- Settings → Notification preferences: toggle still PATCHes and re-fetches (existing P6 behavior).

---

## Deferred (document only; fix when product asks)

| Item | Notes |
|------|--------|
| Delete account | UI confirm with no API — [`setting_screen.dart`](lib/screens/profile_screen/settings_screen/setting_screen.dart) TODO |
| Create note without `projectId` | Local fallback author `Marc G.` — [`create_note_screen.dart`](lib/screens/notes_screen/create_note_screen.dart); fix navigation, not copy |
| Socket note / `updatedProject` | Employee app limitation; REST + refresh — see [BACKEND_INTEGRATION_PLAN.md](BACKEND_INTEGRATION_PLAN.md) Phase 2 deferrals |

---

## Publish checklist (after code changes)

1. Run `flutter test` and `python3 ci/p2_static_verify.py` in `alpha_track_app/`.
2. `rsync` to `arronglewert_alpha_track-dev/` (no `--delete` on clone).
3. Tag only if build changes ship (e.g. `v1.0.10`); Play internal smoke: Phase 1 + Phase 2 rows above.

**Sign-off:** Developer on one release APK/AAB; no full [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) run required for these fixes unless push/prefs regress during smoke.
