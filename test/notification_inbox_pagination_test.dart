import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/screens/notification_screen/notification_inbox_pagination.dart';
import 'package:flutter_test/flutter_test.dart';

Datum _item(String id) => Datum(id: id, title: id, isRead: false);

void main() {
  group('NotificationInboxPagination.mergePageIntoList', () {
    test('page 1 replaces existing list', () {
      final result = NotificationInboxPagination.mergePageIntoList(
        existing: [_item('a'), _item('b')],
        pageItems: [_item('1'), _item('2')],
        page: 1,
        isRefresh: false,
      );
      expect(result.map((e) => e.id), ['1', '2']);
    });

    test('refresh replaces existing list', () {
      final result = NotificationInboxPagination.mergePageIntoList(
        existing: [_item('old')],
        pageItems: [_item('new')],
        page: 2,
        isRefresh: true,
      );
      expect(result.single.id, 'new');
    });

    test('page 2 appends without duplicating page 1', () {
      final page1 = [_item('n1'), _item('n2')];
      final page2 = [_item('n3')];
      final afterPage2 = NotificationInboxPagination.mergePageIntoList(
        existing: page1,
        pageItems: page2,
        page: 2,
        isRefresh: false,
      );
      expect(afterPage2.map((e) => e.id), ['n1', 'n2', 'n3']);
      expect(afterPage2.map((e) => e.id).toSet().length, 3);
    });

    test('retry on page 1 does not append duplicates', () {
      final stale = [_item('dup'), _item('dup')];
      final fresh = [_item('only')];
      final result = NotificationInboxPagination.mergePageIntoList(
        existing: stale,
        pageItems: fresh,
        page: 1,
        isRefresh: false,
      );
      expect(result.map((e) => e.id), ['only']);
    });
  });

  group('NotificationInboxPagination.shouldLoadMore', () {
    test('triggers within threshold of end', () {
      expect(
        NotificationInboxPagination.shouldLoadMore(
          pixels: 850,
          maxScrollExtent: 1000,
          threshold: 200,
        ),
        isTrue,
      );
      expect(
        NotificationInboxPagination.shouldLoadMore(
          pixels: 100,
          maxScrollExtent: 1000,
        ),
        isFalse,
      );
    });

    test('does not trigger when extent is zero', () {
      expect(
        NotificationInboxPagination.shouldLoadMore(
          pixels: 0,
          maxScrollExtent: 0,
        ),
        isFalse,
      );
    });
  });

  group('mark read PATCH URL', () {
    test('builds single-notification path without double slash', () {
      const id = '507f1f77bcf86cd799439011';
      final url = NotificationInboxPagination.markReadPatchUrl(
        ApiUrls.notificationMarkReadBase,
        id,
      );
      expect(url, '${ApiUrls.notificationMarkReadBase}$id');
      expect(url, contains('/notifications/$id'));
      expect(url, isNot(contains('//507f')));
    });
  });
}
