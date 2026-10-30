import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/notification_routing/notification_routing.dart';
import 'package:alpha_track/utils/notification_routing/pending_notification_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a tab destination is held until navigation is ready', () {
    final pending = PendingNotificationRoute();
    pending.enqueue(
      destinationForNotificationCategory('project').withNotificationId('n1'),
    );

    expect(pending.take(), isNull);

    pending.markReady();
    final taken = pending.take();

    expect(taken?.route, AppRoute.bottomNavigation);
    expect(taken?.tabIndex, 1);
    expect(taken?.notificationId, 'n1');
    expect(taken?.projectId, isNull);
    expect(pending.take(), isNull);
  });

  test('a project id is held until navigation is ready', () {
    final pending = PendingNotificationRoute();
    pending.enqueue(
      destinationForNotification(
        category: 'project',
        notificationId: 'n1',
        projectId: 'proj-1',
      ),
    );

    expect(pending.take(), isNull);
    pending.markReady();
    final taken = pending.take();

    expect(taken?.route, AppRoute.projectDetailsScreen);
    expect(taken?.projectId, 'proj-1');
    expect(taken?.notificationId, 'n1');
    expect(taken?.opensTab, isFalse);
  });

  test('a newer tap replaces the one still waiting', () {
    final pending = PendingNotificationRoute();
    pending.enqueue(destinationForNotificationCategory('leave'));
    pending.enqueue(
      destinationForNotificationCategory('attendance').withNotificationId(' '),
    );
    pending.markReady();

    final taken = pending.take();
    expect(taken?.tabIndex, 0);
    expect(taken?.notificationId, isNull);
  });
}
