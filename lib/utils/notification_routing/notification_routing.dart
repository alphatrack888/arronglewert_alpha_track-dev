import 'package:alpha_track/core/app_route/app_route.dart';

/// Where a notification tap should land. A [tabIndex] switches the existing
/// tab shell. A null [tabIndex] pushes [route].
class NotificationDestination {
  final String route;
  final int? tabIndex;
  final String? notificationId;
  final String? projectId;

  const NotificationDestination({
    required this.route,
    this.tabIndex,
    this.notificationId,
    this.projectId,
  });

  bool get opensTab => tabIndex != null && projectId == null;

  NotificationDestination withNotificationId(String? id) {
    final trimmed = id?.trim() ?? '';
    return NotificationDestination(
      route: route,
      tabIndex: tabIndex,
      notificationId: trimmed.isEmpty ? null : trimmed,
      projectId: projectId,
    );
  }

  NotificationDestination withProjectId(String? id) {
    final trimmed = id?.trim() ?? '';
    if (trimmed.isEmpty) return this;
    return NotificationDestination(
      route: AppRoute.projectDetailsScreen,
      notificationId: notificationId,
      projectId: trimmed,
    );
  }
}

/// Category destination, overridden by a project the employee can still open.
NotificationDestination destinationForNotification({
  String? category,
  String? notificationId,
  String? projectId,
}) {
  return destinationForNotificationCategory(category)
      .withNotificationId(notificationId)
      .withProjectId(projectId);
}

/// Category destinations for a push tap and an inbox row tap.
NotificationDestination destinationForNotificationCategory(String? category) {
  switch (category) {
    case 'leave':
      return const NotificationDestination(route: AppRoute.leaveScheduleScreen);
    case 'payroll':
      return const NotificationDestination(route: AppRoute.payRoleScreen);
    case 'attendance':
    case 'overtime':
      return const NotificationDestination(
        route: AppRoute.bottomNavigation,
        tabIndex: 0,
      );
    case 'project':
      return const NotificationDestination(
        route: AppRoute.bottomNavigation,
        tabIndex: 1,
      );
    case 'report':
      return const NotificationDestination(route: AppRoute.reportScreen);
    case 'account':
    case 'subscription':
    default:
      return const NotificationDestination(route: AppRoute.notificationScreen);
  }
}
