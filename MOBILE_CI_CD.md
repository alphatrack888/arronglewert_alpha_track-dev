# Mobile CI/CD

Production Android application ID and iOS bundle ID: `com.marc.alphatrack`.
The client has confirmed both store records and signing setup. Implementation
proceeds on that basis; there is no additional identity-verification prerequisite.

## What runs

- **Mobile CI** runs on pull requests to `main` and pushes to `main`.
  It resolves locked Dart dependencies, runs analysis, Flutter tests, and tests
  for release preparation. Existing analyzer warnings remain visible but do not
  block; errors and failing tests do.
- **Mobile release** is manually started from `main`. It reruns those checks,
  builds Android, iOS, or both, and saves the signed artifacts for 30 days.
- Select **Upload** to send the Android AAB to **Play internal testing** and
  the iOS IPA to **TestFlight**. No production-track rollout or public App Store
  submission is performed. A TestFlight upload still needs Apple processing.
- Flutter comes from `.fvmrc` (3.38.5), Android uses Java 17, and iOS builds on
  GitHub macOS with Xcode 26.2. No Mac is needed on your Windows PC to run CI.
- Builds use temporary signing files and an isolated Apple keychain. Artifacts
  contain application binaries and symbols, never keystores or private keys.

## Add GitHub Secrets

Use the **Flutter repository** (`arronglewert_alpha_track-dev`), not the backend
or dashboard repositories: Settings → Secrets and variables → Actions →
New repository secret. All values below are **Secrets**, not Variables.

The jobs reference a GitHub environment named `mobile-release`. You may put
these secrets in that environment instead of repository secrets. Restrict that
environment to `main`. No additional human approval is required by the workflow.

### Android

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64 contents of the existing production upload keystore (`upload-keystore.jks`) |
| `ANDROID_KEY_ALIAS` | The alias from your working `android/key.properties` |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_GOOGLE_SERVICES_JSON_BASE64` | Base64 of `android/app/google-services.json` |
| `PLAY_SERVICE_ACCOUNT_JSON` | Full, unencoded JSON of the Google service account authorized to upload this app in Play Console; required only when Upload is selected |

Use the existing upload key. The Play service account credential is separate
from the Firebase Android client configuration and the backend's Firebase Admin
credential. Grant the service account access to this app's testing releases and
enable the Google Play Android Developer API for its Cloud project.

### iOS

| Secret | Value |
| --- | --- |
| `IOS_DISTRIBUTION_P12_BASE64` | Base64 of an Apple Distribution certificate exported with its private key as a .p12 |
| `IOS_DISTRIBUTION_P12_PASSWORD` | Password used when exporting that .p12 (empty is supported for a passwordless export) |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of the App Store distribution .mobileprovision for this app, with Push Notifications enabled |
| `APPLE_TEAM_ID` | Apple Developer team ID owning this app |
| `IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64` | Base64 of `ios/Runner/GoogleService-Info.plist` |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect team API key ID; upload only |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID for that team API key; upload only |
| `APP_STORE_CONNECT_KEY_BASE64` | Base64 of the App Store Connect .p8 private key; upload only |

Use an App Store Connect API key with access to upload this app. This is
separate from the APNs key used by Firebase. The distribution profile must
include the certificate supplied in the .p12.

### Encode files from Git Bash on your PC

Run in the Flutter project folder. This copies the encoded value to the Windows
clipboard without printing it. Paste directly into the matching GitHub Secret.

```bash
base64 -w 0 upload-keystore.jks | clip.exe
base64 -w 0 android/app/google-services.json | clip.exe
base64 -w 0 ios/Runner/GoogleService-Info.plist | clip.exe
```

For client-provided Apple files, use their actual paths:

```bash
base64 -w 0 "/c/path/to/distribution.p12" | clip.exe
base64 -w 0 "/c/path/to/distribution.mobileprovision" | clip.exe
base64 -w 0 "/c/path/to/AuthKey_KEYID.p8" | clip.exe
```

Copy the Play JSON without base64: `cat "/c/path/to/play-service-account.json" | clip.exe`.
Do not commit credential files or paste their contents into chat.

## First release

1. Commit and push the Flutter project changes, including the workflows,
   `ci/`, `fastlane/`, `Gemfile`, updated `pubspec.lock`, and the earlier
   production app changes. Keep `key.properties` and private keys ignored.
2. Add the secrets for each platform you intend to build.
3. In Actions, open **Mobile release** → **Run workflow**, select `main`.
4. Choose `android`, `ios`, or `both`. Enter the intended marketing version,
   e.g. `1.0.1`, and an **unused build number higher than prior uploads**.
   When building both, choose a number valid for both stores. These inputs
   override `1.0.0+1` in pubspec without modifying it.
5. Select **Upload** to deliver directly to testing, or leave it off to download
   signed artifacts first. The release job waits for checks to pass.
6. Install through Play internal testing / TestFlight. Exercise login, clock
   in/out, location, media, and notification taps with the app closed and open.
7. After acceptance, promote the tested Android release in Play Console and
   submit the tested iOS build in App Store Connect. Public publication remains
   a store-console action.

If only one platform upload fails, rerun that failed job. Do not upload the same
version code twice after a successful upload. For a new run select the failed
platform or use a new build number.

## Dependency locks and first hosted run

Dart resolution uses `pubspec.lock` with `--enforce-lockfile`. Fastlane and
CocoaPods are pinned in `Gemfile`. The first macOS run resolves the existing
outdated `ios/Podfile.lock` (which predates Firebase pods) and produces
`Gemfile.lock`. Download the **ios-dependency-locks** artifact and commit both
resolved locks after the build passes. Until that is done, transitive Ruby and
new native dependency resolution is not fully locked.

Do not run the CI preparation scripts against your local signing files; they
are intended for disposable GitHub runners.

## If a run fails

- Missing secrets: add the secret under its exact name above, then rerun.
- Signing rejected: use the existing client's matching keystore/certificate and
  profile; the workflow does not generate replacement identities.
- Play reports the app is a draft: finish the listing's initial Play Console
  setup/manual upload before automated completed internal releases.
- Duplicate build: choose a new build number.
- iOS CocoaPods/native build failure: use the macOS job log; local Windows checks
  cannot validate Xcode dependencies.
- Upload succeeded but TestFlight has no available build yet: check Apple
  processing and any export compliance questions in App Store Connect.
- macOS runner no longer has the selected Xcode: update `DEVELOPER_DIR` to an
  installed stable Xcode that meets Apple's SDK requirement.

References:
[Flutter continuous delivery](https://docs.flutter.dev/deployment/cd),
[Play uploads with fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/),
[TestFlight uploads](https://docs.fastlane.tools/actions/pilot/),
[Apple SDK requirements](https://developer.apple.com/news/upcoming-requirements/).
