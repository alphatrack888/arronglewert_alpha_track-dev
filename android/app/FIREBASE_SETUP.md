# Production Android Firebase setup

The production application ID and namespace are `com.marc.alphatrack`.

Replace `android/app/google-services.json` with the download for that Android
app in Firebase project `alphatrack-2026`. The existing local file and the copy
in `cred/` belong to the test app `com.marcgelwertz.alphatrack`.
They have been preserved; do not edit their package name.

Gradle validates the application ID before applying Google Services.
A missing or mismatched file fails with instructions.

The notification permission, default channel, Google Services plugin and Flutter
Firebase dependencies are configured. Supply the existing production upload key
through `android/key.properties`; confirm it belongs to the production Play app.

After installing the correct config, run `flutter pub get`, tests, and a signed
`flutter build appbundle --release`. Test token registration, background push,
cold-start notification taps, and logout on a device with Google Play services.
