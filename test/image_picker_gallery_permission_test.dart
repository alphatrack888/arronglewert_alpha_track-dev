import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('galleryAndroidPermissionKindForSdk', () {
    test('uses photos on API 33+', () {
      expect(galleryAndroidPermissionKindForSdk(33), 'photos');
      expect(galleryAndroidPermissionKindForSdk(34), 'photos');
    });

    test('uses storage below API 33', () {
      expect(galleryAndroidPermissionKindForSdk(32), 'storage');
      expect(galleryAndroidPermissionKindForSdk(29), 'storage');
    });
  });

  group('galleryPermissionLabelForSdk', () {
    test('labels match permission kind', () {
      expect(galleryPermissionLabelForSdk(33), 'Photos');
      expect(galleryPermissionLabelForSdk(32), 'Storage');
    });
  });

  group('isGalleryPermissionSufficient', () {
    test('granted and limited allow pick', () {
      expect(isGalleryPermissionSufficient(PermissionStatus.granted), isTrue);
      expect(isGalleryPermissionSufficient(PermissionStatus.limited), isTrue);
    });

    test('denied and restricted block pick', () {
      expect(isGalleryPermissionSufficient(PermissionStatus.denied), isFalse);
      expect(
        isGalleryPermissionSufficient(PermissionStatus.permanentlyDenied),
        isFalse,
      );
    });
  });
}
