# Production iOS Firebase setup

Runner uses `com.marc.alphatrack`. The matching `GoogleService-Info.plist`
from `cred/` is installed and included in Runner's Copy Bundle Resources.
Push Notifications and Background Modes are enabled in the project.
All Runner build configurations reference `Runner/Runner.entitlements`.

Remaining account/build steps on a Mac:

1. Verify the existing Apple development team owns the production bundle ID.
   Select its provisioning profiles and signing identity in Xcode.
2. In Firebase project `alphatrack-2026`, verify an APNs authentication key
   is uploaded for the production iOS app with the correct Apple team/key ID.
3. Run `flutter pub get`, then `cd ios && pod install`. Commit the resulting
   Podfile.lock after checking it; the current lockfile predates Firebase.
4. Open `Runner.xcworkspace`, build on a device, and archive/export for distribution.
   The source entitlement uses development for local device builds; Xcode's
   distribution signing/export must produce the production APNs entitlement.
   Inspect the exported signed app's entitlements before TestFlight upload.
5. Test permission/token registration, foreground and background push, taps from
   a terminated app, and logout. Store signing and APNs delivery cannot be
   validated by merely inspecting the Firebase plist.

See https://firebase.google.com/docs/cloud-messaging/flutter/get-started.
