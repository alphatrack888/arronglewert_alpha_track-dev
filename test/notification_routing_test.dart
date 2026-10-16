import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/notification_routing/notification_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('leave notification category routes to leave schedule screen', () {
    expect(
      routeForNotificationCategory('leave'),
      AppRoute.leaveScheduleScreen,
    );
  });

  test('unknown category returns null', () {
    expect(routeForNotificationCategory('unknown'), isNull);
  });
}
