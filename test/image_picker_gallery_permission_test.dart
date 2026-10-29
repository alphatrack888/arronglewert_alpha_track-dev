import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  test('gallery pick does not require a storage or photos grant first', () {
    expect(galleryRequiresPermissionBeforePick(), isFalse);
  });

  group('cameraDenialOpensSettings', () {
    test('a normal denial does not open Settings', () {
      expect(cameraDenialOpensSettings(PermissionStatus.denied), isFalse);
      expect(cameraDenialOpensSettings(PermissionStatus.granted), isFalse);
      expect(cameraDenialOpensSettings(PermissionStatus.limited), isFalse);
    });

    test('a permanent or restricted denial opens Settings', () {
      expect(
        cameraDenialOpensSettings(PermissionStatus.permanentlyDenied),
        isTrue,
      );
      expect(cameraDenialOpensSettings(PermissionStatus.restricted), isTrue);
    });
  });
}
