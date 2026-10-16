# Gallery permissions (Android)

## Behavior

Profile gallery and avatar flows use [`ImagePickerService`](lib/services/image_picker_service/image_picker_service.dart):

- **Android 13+ (API 33+):** Runtime `READ_MEDIA_IMAGES` via `permission_handler` (`Permission.photos`). Partial / limited photo access (`isLimited`) is treated as success.
- **Android 12 and below:** `READ_EXTERNAL_STORAGE` (manifest `maxSdkVersion="32"`) via `Permission.storage`.
- **Denied once:** Gallery does not open; no Settings deep link (user can try again).
- **Permanently denied:** In-app dialog offers **Settings**, where Photos/Storage toggles are visible because permissions are declared in [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).

Video library, write-external-storage, and `MANAGE_EXTERNAL_STORAGE` are **not** requested (release CI still forbids them).

## History

Phase 4.1 previously used a **picker-first** approach (manifest stripped image/storage permissions) to avoid a dead-end Settings screen when Dart requested photos without manifest entries. That was reverted in favor of the **classic** model: declare permissions and request them before `ImagePicker.pickImage(gallery)`.

## Google Play

For releases that include `READ_MEDIA_IMAGES`, complete the Play Console **Photo and video permissions** declaration:

- **Use case:** User uploads images to their profile gallery or avatar (infrequent, user-initiated).
- **Not used for:** Background scanning, full-library browsing, or video access.

## Upload flow (backend alignment)

| Step | Client | Server (`time-tracker`) |
|------|--------|-------------------------|
| Pick | `ImagePickerService` → local `File` | — |
| Upload | `ProfileRepository.uploadGalleryImage` — `POST /gallery/`, multipart field **`images`** | `fileAndBodyProcessorUsingDiskStorage` → Cloudinary URLs in `body.images[]` |
| Persist | On `success: true`, refresh `GET /gallery/` | `GalleryServices.createGallery` — `EMPLOYEES` role |
| UI | Overlay while `isUploading`; success/error snackbar with server message when available | JPEG/PNG/WebP up to 10 MB |

Requires a logged-in **employee** account (not guest). Upload failures often mean auth, role, invalid file type, or Cloudinary config on the server.

## Manual smoke

| Device | Steps |
|--------|--------|
| API 33+ | Profile → Gallery → pick → grant Photos → picker opens |
| API 33+ deny | Deny with “don’t ask again” → Settings dialog → enable Photos |
| API 30–32 | Grant Storage → picker opens |
| API 34+ limited | Select specific photos only → pick still works |

Release check after `flutter build appbundle --release`:

```bash
python3 ci/check_android_permissions.py
```
