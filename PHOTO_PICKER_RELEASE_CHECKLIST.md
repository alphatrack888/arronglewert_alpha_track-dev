# Photo picker policy fix: release checks

Gallery access uses image_picker's system picker without Permission.photos or
Permission.storage. Single and multiple selection request no full metadata.
Camera authorization is delegated to image_picker on iOS; Android uses its camera
intent. iOS camera and photo usage descriptions remain present.

Android main manifest uses tools:node="remove" for broad photo/video and legacy
storage permissions. These are removal directives, not permission requests.
Debug and profile declarations are removed too. Microphone and location features
retain their existing permissions.

## Automated checks

- flutter test --no-pub
- python -B -m unittest discover -s ci -p 'test_*.py'
- flutter analyze --no-pub --no-fatal-infos --no-fatal-warnings
- After building the release AAB: python ci/check_android_permissions.py

The release workflow runs the packaged-manifest check after building and before
uploading artifacts or submitting to Google Play. Missing manifests fail the check.
The check covers dependency-merged permissions, not just source XML.

## Device verification before public release

Use Android 12 and Android 13+ (including a current Android version), and a real
iPhone on a supported iOS version. Check:

- Profile picture and profile gallery: select a photo, take a photo, cancel.
- Notes, project notes and mixed notes: select multiple photos, preview and upload.
- Photo access denied or limited in OS settings: system selection still works
  where supported without a broad permission gate.
- Camera allowed, denied and restricted: useful error handling, no crash.
- iPhone HEIC and cloud-backed photos: selection and upload.
- Background/foreground during selection; Android activity recreation. If the OS
  kills the process, check for lost selections and do not assume drafts survive.
  This patch does not add persistent draft or lost-picker-result recovery.
- Voice notes, PDF downloads, notifications and location tracking remain usable.

## Store rollout

Merge the change through a PR. Use a new, unused release tag/version and build
number for Android internal testing. The current workflow runs iOS releases
through workflow_dispatch; use it for the TestFlight build.

In Play Console, inspect Update affected bundles and replace/deactivate the
affected releases in the tracks identified there before resubmitting. A local
source change does not fix already-uploaded bundles. Review the corrected builds
on both platforms before public publication.
