import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('shouldRequestGalleryPermissionBeforePick', () {
    test('returns false on API 33+ (Photo Picker)', () {
      expect(shouldRequestGalleryPermissionBeforePick(33), isFalse);
      expect(shouldRequestGalleryPermissionBeforePick(34), isFalse);
    });

    test('returns true below API 33', () {
      expect(shouldRequestGalleryPermissionBeforePick(32), isTrue);
      expect(shouldRequestGalleryPermissionBeforePick(29), isTrue);
    });
  });

  group('isGalleryPermissionSufficient', () {
    test('granted and limited allow pick', () {
      expect(isGalleryPermissionSufficient(PermissionStatus.granted), isTrue);
      expect(isGalleryPermissionSufficient(PermissionStatus.limited), isTrue);
    });

    test('denied blocks pick', () {
      expect(isGalleryPermissionSufficient(PermissionStatus.denied), isFalse);
    });
  });
}
