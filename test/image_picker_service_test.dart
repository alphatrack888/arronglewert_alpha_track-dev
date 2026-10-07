import 'dart:io';

import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class FakeImagePicker extends ImagePicker {
  ImageSource? source;
  bool? fullMetadata;
  XFile? result;
  List<XFile> multiple = [];
  PlatformException? failure;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    this.source = source;
    fullMetadata = requestFullMetadata;
    if (failure != null) throw failure!;
    return result;
  }

  @override
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async {
    fullMetadata = requestFullMetadata;
    if (failure != null) throw failure!;
    return multiple;
  }
}

void main() {
  testWidgets(
    'gallery and camera return files without a permission preflight',
    (tester) async {
      final temp = Directory.systemTemp.createTempSync('picker-test');
      addTearDown(() => temp.deleteSync(recursive: true));
      final file = File('${temp.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
      final picker = FakeImagePicker()..result = XFile(file.path);
      final service = ImagePickerService(picker: picker);
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const Scaffold();
            },
          ),
        ),
      );
      // No permission_handler platform mock: a native preflight would fail.
      expect(
        (await tester.runAsync(() => service.pickFromGallery(context)))?.path,
        file.path,
      );
      expect(picker.source, ImageSource.gallery);
      expect(picker.fullMetadata, isFalse);
      expect(
        (await tester.runAsync(() => service.pickFromCamera(context)))?.path,
        file.path,
      );
      expect(picker.source, ImageSource.camera);
      expect(picker.fullMetadata, isFalse);
    },
  );

  testWidgets('cancellation is silent and iOS camera denial offers Settings', (
    tester,
  ) async {
    final picker = FakeImagePicker();
    final service = ImagePickerService(picker: picker);
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );
    expect(await service.pickFromGallery(context), isNull);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    picker.failure = PlatformException(code: 'camera_access_denied');
    expect(await service.pickFromCamera(context), isNull);
    await tester.pumpAndSettle();
    expect(find.text('Camera Permission Required'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  test(
    'multiple selection avoids full metadata and preserves cancellation',
    () async {
      final picker = FakeImagePicker();
      final service = ImagePickerService(picker: picker);
      expect(await service.pickMultipleImages(), isEmpty);
      picker.multiple = [XFile('/first.jpg'), XFile('/second.jpg')];
      expect((await service.pickMultipleImages()).length, 2);
      expect(picker.fullMetadata, isFalse);
    },
  );

  test('restricted access has a distinct message', () {
    expect(
      ImagePickerService.errorMessage(
        PlatformException(code: 'camera_access_restricted'),
      ),
      contains('restricted'),
    );
  });
}
