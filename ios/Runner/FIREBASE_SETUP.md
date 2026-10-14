# iOS Firebase / FCM (redesign)

**Bundle ID:** `com.marcgelwertz.alphatrack` (see Xcode project settings).

Push is **not configured** until you:

1. Register an iOS app with this bundle ID in Firebase project **alphatrack-2026**.
2. Upload your APNs authentication key in Firebase Console.
3. Download `GoogleService-Info.plist` into this `ios/Runner/` directory.
4. Enable Push Notifications capability in Xcode for the Runner target.

Do **not** reuse `cred/GoogleService-Info.plist` — it is for legacy `com.marc.alphatrack`.
