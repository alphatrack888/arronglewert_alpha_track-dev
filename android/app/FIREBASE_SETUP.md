# Android Firebase configuration

Production Android application ID: **`com.marcgelwertz.alphatrack`**.

1. Download `google-services.json` from Firebase project **alphatrack-2026** for that package.
2. Place it at `android/app/google-services.json` (not committed — use `cred/google-services.json` locally or CI secret `ANDROID_GOOGLE_SERVICES_JSON_BASE64`).

The Gradle build verifies the file contains a client for `com.marcgelwertz.alphatrack`.

## iOS (redesign)

Bundle ID **`com.marcgelwertz.alphatrack`** requires its own `GoogleService-Info.plist` in `ios/Runner/`. The `cred/GoogleService-Info.plist` in this repo targets legacy **`com.marc.alphatrack`** and must not be used for the redesign app. See `ios/Runner/FIREBASE_SETUP.md`.
