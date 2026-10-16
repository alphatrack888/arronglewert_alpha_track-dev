import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('skipGalleryPermissionForAndroidSdk', () {
    test('returns true for all Android API levels', () {
      expect(skipGalleryPermissionForAndroidSdk(33), isTrue);
      expect(skipGalleryPermissionForAndroidSdk(32), isTrue);
      expect(skipGalleryPermissionForAndroidSdk(29), isTrue);
    });
  });
}
