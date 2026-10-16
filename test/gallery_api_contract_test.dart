import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/gallery_api_contract.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseGalleryListResponse', () {
    test('parses successful list', () {
      final outcome = parseGalleryListResponse({
        'statusCode': 200,
        'success': true,
        'message': 'Gallerys retrieved successfully',
        'meta': {'page': 1, 'limit': 1, 'total': 5},
        'data': [
          {
            '_id': '507f1f77bcf86cd799439011',
            'image': 'https://res.cloudinary.com/demo/image/upload/a.jpg',
          },
        ],
      });
      expect(outcome.ok, isTrue);
      expect(outcome.items, hasLength(1));
      expect(outcome.totalCount, 5);
      expect(outcome.items.first.id, '507f1f77bcf86cd799439011');
      expect(outcome.items.first.image, contains('cloudinary'));
    });

    test('empty data is valid success', () {
      final outcome = parseGalleryListResponse({
        'success': true,
        'meta': {'page': 1, 'limit': 0, 'total': 0},
        'data': [],
      });
      expect(outcome.ok, isTrue);
      expect(outcome.items, isEmpty);
      expect(outcome.totalCount, 0);
    });

    test('missing success fails', () {
      final outcome = parseGalleryListResponse({
        'success': false,
        'message': 'denied',
      });
      expect(outcome.ok, isFalse);
      expect(outcome.serverMessage, 'denied');
    });

    test('non-map body fails', () {
      expect(parseGalleryListResponse(null).ok, isFalse);
    });
  });

  group('parseGalleryUploadResponse', () {
    test('parses 201 create with created items', () {
      final result = parseGalleryUploadResponse(
        {
          'statusCode': 201,
          'success': true,
          'message': 'Gallery created successfully',
          'data': [
            {
              '_id': '507f1f77bcf86cd799439012',
              'image': 'https://res.cloudinary.com/demo/image/upload/b.jpg',
            },
          ],
        },
        201,
      );
      expect(result.success, isTrue);
      expect(result.createdItems, hasLength(1));
      expect(result.createdItems.first.id, '507f1f77bcf86cd799439012');
    });

    test('maps 403 to employee key', () {
      final result = parseGalleryUploadResponse(
        {'success': false, 'message': 'forbidden'},
        403,
      );
      expect(result.success, isFalse);
      expect(result.message, 'galleryUploadEmployeeOnly');
    });

    test('maps 401 to auth key', () {
      final result = parseGalleryUploadResponse(null, 401);
      expect(result.message, 'galleryUploadAuthRequired');
    });
  });

  group('mergeGalleryItems', () {
    test('prepends created and dedupes', () {
      final existing = [
        Datum(id: 'a', image: 'https://example.com/a.jpg'),
        Datum(id: 'b', image: 'https://example.com/b.jpg'),
      ];
      final created = [
        Datum(id: 'c', image: 'https://example.com/c.jpg'),
        Datum(id: 'a', image: 'https://example.com/a-new.jpg'),
      ];
      final merged = mergeGalleryItems(existing: existing, created: created);
      expect(merged.map((e) => e.id).toList(), ['c', 'a', 'b']);
    });

    test('fromServer replaces merged list', () {
      final merged = mergeGalleryItems(
        existing: [Datum(id: 'x', image: 'u')],
        created: [Datum(id: 'y', image: 'v')],
        fromServer: [Datum(id: 'z', image: 'w')],
      );
      expect(merged, hasLength(1));
      expect(merged.first.id, 'z');
    });
  });

  group('gallery translation keys', () {
    test('english map contains gallery error keys', () {
      final english = AppTranslation().keys['english']!;
      expect(english, contains('galleryUploadEmployeeOnly'));
      expect(english, contains('galleryUploadAuthRequired'));
      expect(english, contains('galleryImageUnreadable'));
      expect(english, contains('galleryUploadRefreshFailed'));
    });
  });
}
