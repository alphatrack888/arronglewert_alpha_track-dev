# Gallery permissions and upload (Android)

## Pick (docs-aligned)

Profile gallery and avatar use [`ImagePickerService`](lib/services/image_picker_service/image_picker_service.dart) with the **system Photo Picker** where possible.

| Android API | Before gallery pick | Manifest |
|-------------|---------------------|----------|
| **33+** | No `Permission.photos` — open picker directly | `READ_MEDIA_IMAGES` / legacy storage **stripped** (`tools:node="remove"`) |
| **32−** | `Permission.storage` if needed | Same strip; plugins may merge legacy entries — CI verifies release bundle |

[`main.dart`](lib/main.dart) sets `ImagePickerAndroid.useAndroidPhotoPicker = true` on supported versions.

**Limited / partial access (Android 14+):** Granting “only N photos” does not block the system picker from letting the user choose a photo for this upload; that is expected OS behavior.

## Upload

| Step | Client | Server |
|------|--------|--------|
| Read pick | `materializePickedImageFile` → `readAsBytes` → temp file | — |
| POST | `MultipartFile.fromBytes`, field **`images`** | Cloudinary → `body.images[]` |
| Auth | Bearer token | `EMPLOYEES` role only |
| UI | Overlay + banner + snackbar after overlay | — |

Lost pick after process death: [`GalleryScreenController.recoverLostPickerImage`](lib/screens/profile_screen/gallery_screen/controller/gallery_screen_controller.dart) calls `ImagePicker.retrieveLostData()` on screen open.

## Release CI

[`ci/check_android_permissions.py`](ci/check_android_permissions.py) fails release builds that include broad `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`, video, or write/manage storage.

## API contract (client parsers)

Parsers live in [`gallery_api_contract.dart`](lib/screens/profile_screen/gallery_screen/gallery_api_contract.dart) and are covered by [`test/gallery_api_contract_test.dart`](test/gallery_api_contract_test.dart).

**GET** `/api/v1/gallery/` (employee, 200):

```json
{
  "success": true,
  "message": "Gallerys retrieved successfully.",
  "meta": { "page": 1, "limit": 1, "total": 12 },
  "data": [
    { "_id": "507f1f77bcf86cd799439011", "image": "https://res.cloudinary.com/.../photo.jpg" }
  ]
}
```

The gallery screen shows **`meta.total`** as the image count in the header (falls back to `data.length` if `meta` is omitted).

**POST** `/api/v1/gallery/` multipart field `images` (employee, 201):

```json
{
  "success": true,
  "message": "Gallery created successfully.",
  "data": [
    { "_id": "507f1f77bcf86cd799439012", "image": "https://res.cloudinary.com/.../new.jpg" }
  ]
}
```

After a successful POST, the grid **prepends `data` docs** immediately, then refreshes via GET (newest-first on server via `createdAt` sort). Failed GET after upload shows `galleryUploadRefreshFailed` but keeps POST-merge tiles.

## HEIC / image formats

**HEIC is not supported** by the server upload pipeline. Users should pick **JPEG or PNG** (or use the camera). WebP is accepted when the deployed API includes `image/webp` in [`processReqBody.ts`](../../time-tracker/src/app/middleware/processReqBody.ts).

## Automated checks

```bash
cd arronglewert_alpha_track-dev && flutter test test/gallery_api_contract_test.dart
cd arronglewert_alpha_track-dev/ci && python3 -m unittest test_android_permissions.py
cd time-tracker && npm test -- gallery.route.test.ts
```

## Manual bulletproof checklist

1. Employee account, fresh debug APK from `arronglewert_alpha_track-dev`.
2. Gallery → pick JPEG/PNG → green banner + snackbar after overlay.
3. New tile shows `https://` Cloudinary URL (not empty / file path).
4. Pull-to-refresh → same images, newest first.
5. Delete one image → removed from grid.
6. Airplane mode on open → error banner/snackbar (not silent empty gallery).
7. Company login → gallery upload blocked (`galleryUploadEmployeeOnly` if attempted).

## Manual smoke

1. API 34+ device, employee login → Gallery → pick → green banner + image in grid.
2. API 33+ → no Photos permission in app Settings required for pick.
3. API 30 emulator → deny storage → error banner; grant → pick works.
4. Airplane mode after pick → red failed-upload banner.
5. Build from `arronglewert_alpha_track-dev` (`flutter build apk --debug`).
