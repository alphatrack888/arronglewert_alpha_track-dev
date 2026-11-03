# iOS Firebase / FCM (redesign)

**Bundle ID:** `com.marcgelwertz.alphatrack`  
**Firebase project:** `alphatrack-2026`

## In the repo

- `GoogleService-Info.plist` in this directory (gitignored; CI writes it from `IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`)
- Push entitlement: `Runner.entitlements` (`aps-environment` = development) for Debug; `RunnerRelease.entitlements` (`production`) for Release and Profile
- Dart enables `setForegroundNotificationPresentationOptions` (alert, badge, sound). Foreground iOS uses the system banner; there is no snackbar and no second local post
- Do **not** add `UIBackgroundModes` / `remote-notification` for a title/body banner
- Do **not** reuse a plist for legacy `com.marc.alphatrack`

## Operator checks (required before device push works)

Confirm with the Firebase / Apple account owner:

1. An APNs authentication key (`.p8`) is uploaded in Firebase Console → Project **alphatrack-2026** → Cloud Messaging → Apple app `com.marcgelwertz.alphatrack`.
2. The App Store provisioning profile used as `IOS_PROVISIONING_PROFILE_BASE64` has Push Notifications enabled. Replace that GitHub secret if they issue a new profile.

Without (1), `getAPNSToken` / FCM `getToken` fail even when the plist and entitlements are correct.

## Device checks (real iPhone, push-capable profile)

1. Login → device registers with `platform: ios` and a non-empty token.
2. App killed or background → one system banner; tap opens the Phase 3/4 destination.
3. App foreground → one system banner (no snackbar); tap still routes.
4. Same `notificationId` within 10s → no snackbar double; one system presentation for that FCM event.
