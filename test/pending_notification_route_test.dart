import 'package:alpha_track/utils/notification_routing/pending_notification_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cold-start tap waits for authenticated navigation and opens once', () {
    final pending = PendingNotificationRoute();
    pending.enqueue('/notifications');
    expect(pending.take(), isNull);
    pending.markReady();
    expect(pending.take(), '/notifications');
    expect(pending.take(), isNull);
  });

  test('warm tap is available after navigation is ready', () {
    final pending = PendingNotificationRoute()..markReady();
    pending.enqueue('/reports');
    expect(pending.take(), '/reports');
  });

  test('logout drops pending navigation and requires a new session', () {
    final pending = PendingNotificationRoute()..markReady();
    pending.enqueue('/old-user-report');
    pending.reset();
    pending.markReady();
    expect(pending.take(), isNull);
    pending.reset();
    pending.enqueue('/new-report');
    expect(pending.take(), isNull);
    pending.markReady();
    expect(pending.take(), '/new-report');
  });
}
