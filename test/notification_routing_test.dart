import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/notification_routing/notification_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('leave opens the leave schedule', () {
    final destination = destinationForNotificationCategory('leave');
    expect(destination.route, AppRoute.leaveScheduleScreen);
    expect(destination.opensTab, isFalse);
  });

  test('payroll opens the pay screen', () {
    final destination = destinationForNotificationCategory('payroll');
    expect(destination.route, AppRoute.payRoleScreen);
    expect(destination.opensTab, isFalse);
  });

  test('attendance and overtime open the home tab', () {
    for (final category in ['attendance', 'overtime']) {
      final destination = destinationForNotificationCategory(category);
      expect(destination.route, AppRoute.bottomNavigation);
      expect(destination.tabIndex, 0);
    }
  });

  test('project opens the projects tab', () {
    final destination = destinationForNotificationCategory('project');
    expect(destination.route, AppRoute.bottomNavigation);
    expect(destination.tabIndex, 1);
  });

  test('a project id opens project details and a missing id keeps the tab', () {
    final withId = destinationForNotification(
      category: 'project',
      projectId: 'proj-1',
    );
    expect(withId.route, AppRoute.projectDetailsScreen);
    expect(withId.projectId, 'proj-1');
    expect(withId.opensTab, isFalse);

    final withoutId = destinationForNotification(category: 'project');
    expect(withoutId.route, AppRoute.bottomNavigation);
    expect(withoutId.tabIndex, 1);

    final overtimeWithoutId = destinationForNotification(category: 'overtime');
    expect(overtimeWithoutId.tabIndex, 0);
    expect(overtimeWithoutId.route, AppRoute.bottomNavigation);
  });

  test('report opens the report screen', () {
    final destination = destinationForNotificationCategory('report');
    expect(destination.route, AppRoute.reportScreen);
    expect(destination.opensTab, isFalse);
  });

  test('account, subscription, null, and unknown open the notification list', () {
    for (final category in ['account', 'subscription', null, 'unknown']) {
      final destination = destinationForNotificationCategory(category);
      expect(destination.route, AppRoute.notificationScreen, reason: '$category');
      expect(destination.opensTab, isFalse, reason: '$category');
    }
  });
}
