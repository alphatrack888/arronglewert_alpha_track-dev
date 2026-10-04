# Android Firebase configuration

The existing production Play listing uses `com.marcgelwertz.alphatrack`.
The Android application ID, namespace, MainActivity and Play upload lane use this ID.
iOS separately uses `com.marc.alphatrack`.

Use `android/app/google-services.json` from Firebase project `alphatrack-2026`.
The current file includes both clients; Google Services selects the client matching
the Android application ID. Do not manually rename a Firebase client's package.

CI restores this file from `ANDROID_GOOGLE_SERVICES_JSON_BASE64`.
Its existing value remains suitable if it contains the production Android client.
The build and release preparation reject configurations without that client.

If replacing the file, download it from Firebase project settings for the Android
app `com.marcgelwertz.alphatrack`, then update the GitHub Secret.
