# Android Firebase setup (required for push notifications)

Phase 11 of `../../../Notification_Reports_Integration_Plan.md` added the FCM
client code (`lib/services/push_notification_service/`), but it needs a real
Firebase project's config file to actually initialize — this repo has no
Firebase CLI login or project access, so that file could not be generated
here.

## What's needed

1. **`google-services.json`**, placed at `android/app/google-services.json`
   (same directory as this file). Get it from the Firebase console, from
   **the same Firebase project already backing `time-tracker`'s
   `firebase-admin` service account** (not a new/separate project — a
   mismatched project means the backend's `sendPushNotification` calls will
   never reach a device registered against a different project).
2. In the Firebase console, register this app's Android package name:
   `com.marcgelwertz.alphatrack` (see `android/app/build.gradle.kts` →
   `applicationId`).

## What happens without it

- `android/app/build.gradle.kts` only applies the `com.google.gms.google-services`
  Gradle plugin **if `google-services.json` is present** — deliberately, so
  the rest of the Android build (everything unrelated to push) isn't broken
  for anyone who hasn't done this setup step yet.
- `lib/main.dart`'s `initializePushNotifications()` catches and logs any
  `Firebase.initializeApp()` failure rather than crashing — the app starts
  and runs normally, just without push, falling back to the existing
  Socket.IO in-app notifications.

## What's already done and doesn't need touching

- `AndroidManifest.xml`: `POST_NOTIFICATIONS` permission (Android 13+) and
  the default notification channel meta-data.
- `pubspec.yaml`: `firebase_core`, `firebase_messaging`, `package_info_plus`.
- `settings.gradle.kts`: the `com.google.gms.google-services` plugin
  version declaration.

## Verifying it worked

Once the real file is in place: `flutter run` on a real Android device
(FCM on emulators is unreliable — see the plan's own exit criteria), log in,
grant the notification permission prompt, and check the `DeviceToken`
collection in the backend for a new row for that user. Full checklist in
`arronglewert_alpha_track-dev/PHASE11_NOTES.md`.
