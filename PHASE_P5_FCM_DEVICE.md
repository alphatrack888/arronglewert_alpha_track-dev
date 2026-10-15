# P5 — FCM & device registration (device verification)

**Build:** Play **internal testing** from **`v1.0.8+`** (splash re-register + deregister URL encode). Baseline **`v1.0.7`** lacks P5.1 fixes.

**Account:** Production employee; push enabled on server (full preference policy = P6).

Record results in [NOTIFICATION_MODULE_REGRESSION.md](NOTIFICATION_MODULE_REGRESSION.md) §4.3 **Push** row.

---

## Automated audit (2026-10-16)

| # | Check | Result | Notes |
|---|--------|--------|-------|
| 1 | Register body | Pass | `token`, `platform` (`android`/`ios`), optional `appVersion` — matches backend Zod schema |
| 2 | Register auth | Pass | `_registerToken` only when access token present |
| 3 | Logout order | Pass | `deregisterCurrentToken` → socket disconnect → `storageClear` in `profile_screen` |
| 4 | Session clear | Pass | `clearSession` removes `registeredDeviceToken` after deregister |
| 5 | Cold start | Pass (P5.1) | Splash: `registerCurrentToken` if no stored device token; else `refreshRegistrationIfNeeded` |
| 6 | DELETE URL | Pass (P5.1) | `DeviceRegisterPaths.deregisterUrl` uses `Uri.encodeComponent` |
| 7 | Background handler | Pass (documented) | Empty handler OK when server sends **notification** payload (system tray when killed) |
| 8 | Dedupe | Pass | `claimForDisplay` + `push_notification_dedupe_test.dart` |
| 9 | Secrets | Pass | `google-services.json` gitignored; CI `ANDROID_GOOGLE_SERVICES_JSON_BASE64` in `prepare_release.py` |

**Pre-check:**

```bash
cd alpha_track_app
python3 ci/p2_static_verify.py
flutter test test/device_register_url_test.dart
flutter test
```

---

## Device checklist

| Step | Pass when | Result | Evidence |
|------|-----------|--------|----------|
| Permission | Android 13+: notifications allowed (or document deny) | Pending device | |
| Login | Logcat: `Device token registered` (do not paste FCM token) | Pending device | |
| Background | App in background → notification on tray | Pending device | |
| Killed | App swiped away / not running → lock screen push | Pending device | |
| Tap routing | Tap notification → expected screen | Pending device | |
| Logout | No push after logout + server trigger | Pending device | |
| Resume | Background → foreground; no register storm (≤ few calls) | Pending device | |

**Trigger:** Backend/admin notification event with push enabled for test user.

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Developer | | |
| Client (optional) | | |

When killed-state push passes, check **BACKEND 3.5** and P5 in [PRODUCTION_PHASED_PLAN.md](PRODUCTION_PHASED_PLAN.md).
