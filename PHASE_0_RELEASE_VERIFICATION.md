# Phase 0 — Release verification (0.1 & 0.5)

**Master gate:** [PRODUCTION_READINESS_GATE.md](PRODUCTION_READINESS_GATE.md) (ordered Steps 1–6 + go/no-go).

Use this checklist after code changes for Phase 0. Record **Pass / Fail**, device, app version, tester, and date.

## 0.1 — `kDemoMode` off in production release

```bash
cd alpha_track_app
# After changing android/gradle.properties, stop old daemons once:
# (cd android && ./gradlew --stop)
flutter build apk --release
# Do NOT pass --dart-define=DEMO_MODE=true
```

Install the APK on a device with **no** existing session (or clear app data).

**After P0 (2026-10-15):** `flutter run` without flags should also require login (debug no longer enables demo by default). UI-only demo: `flutter run --dart-define=DEMO_MODE=true`.

| Check | Expected | Result | Notes |
|-------|----------|--------|-------|
| Cold start | Onboarding or login (not main app without credentials) | | |
| No token | Cannot reach home without logging in | | |
| Logout (returning user) | Splash → **login** (not onboarding); language unchanged | | After P1 |

Optional reviewer build (demo allowed):

```bash
flutter build apk --release --dart-define=DEMO_MODE=true
```

| Check | Expected | Result |
|-------|----------|--------|
| Cold start | Main app without login | |

## 0.5 — Production API defaults

Confirmed in source ([`lib/core/api_urls/api_urls.dart`](lib/core/api_urls/api_urls.dart)):

- `baseUrl` → `https://api.alphatrack.app/api/v1`
- `socketUrl` default → `https://api.alphatrack.app/` (override via `--dart-define=SOCKET_URL=...` for local backend only)

| Check | Expected | Result | Notes |
|-------|----------|--------|-------|
| Authenticated REST | Requests go to `api.alphatrack.app` | | Logcat: path only, no JWT in logs |
| Socket | Connects to production host when not overridden | | |

## Phase 0 smoke (with client)

| Screen / flow | Expected | Result |
|---------------|----------|--------|
| Login → home | Real projects | |
| Project details → **Notes** | API notes or empty; not hardcoded demo lawn notes | |
| Create note on project | Saves via API; list refreshes | |
| Profile / notifications | API data (see [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md)) | |

**Sign-off:** Developer + client name, date, build `1.0.0+17` (or current `pubspec.yaml` version).
