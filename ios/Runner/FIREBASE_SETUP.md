# iOS Firebase setup (required for push notifications)

Phase 11 of `../../../Notification_Reports_Integration_Plan.md` added the FCM
client code (`lib/services/push_notification_service/`). Three things it
needs can't be done in this environment — no macOS/Xcode, no Apple Developer
account, no Firebase CLI login — and have to happen on a Mac with real
credentials:

## 1. `GoogleService-Info.plist`

Download from the Firebase console — **the same Firebase project already
backing `time-tracker`'s `firebase-admin` service account** (not a new one),
with this app's iOS bundle id registered. Add it to `ios/Runner/` via Xcode
(drag into the `Runner` group so it's copied into the app bundle, not just
placed in the folder on disk).

## 2. APNs key/certificate on the Firebase project

In the Firebase console, under Project Settings → Cloud Messaging → Apple
app configuration, upload an APNs authentication key (or certificate) from
the Apple Developer portal. Without this, FCM has no way to actually reach
APNs for this app — device tokens would register fine but no push would
ever arrive.

## 3. Enable capabilities in Xcode

Open `ios/Runner.xcworkspace` in Xcode → Runner target → **Signing &
Capabilities** → **+ Capability** → add **Push Notifications** and
**Background Modes** (check **Remote notifications** under it).

This repo already has the two pieces those capabilities need:
- `Info.plist` → `UIBackgroundModes` = `remote-notification` (done).
- `Runner.entitlements` → `aps-environment` = `development` (done, but
  **not yet wired into the Xcode project** — hand-editing
  `project.pbxproj`'s `CODE_SIGN_ENTITLEMENTS` build setting outside Xcode
  is fragile and unverifiable without Xcode itself, so it was left for
  Xcode's own capability flow, which will either pick up this file by name
  or offer to generate its own — either is fine, just don't end up with
  two).

Change `aps-environment` to `production` in the entitlements file when
archiving for TestFlight/App Store — `development` only works with
development-signed builds talking to APNs' sandbox environment.

## What happens without any of this

`lib/main.dart`'s `initializePushNotifications()` catches and logs any
`Firebase.initializeApp()` failure rather than crashing — the app starts and
runs normally without push, falling back to the existing Socket.IO in-app
notifications.

## Verifying it worked

FCM on the iOS **simulator** is unreliable (the plan's own exit criteria
call this out) — a real device is required. Once all three steps above are
done: run on a real device, log in, grant the permission prompt, and check
the backend's `DeviceToken` collection for a new row. Full checklist in
`arronglewert_alpha_track-dev/PHASE11_NOTES.md`.
