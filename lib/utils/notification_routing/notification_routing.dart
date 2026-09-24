import 'package:alpha_track/core/app_route/app_route.dart';

/// Single source of truth for where a notification tap should land, shared
/// between the in-app list (NotificationScreenController/notification_screen.dart,
/// using the `category` persisted on the fetched Datum) and a live push tap
/// (PushNotificationService, using `category` from the FCM data payload —
/// see time-tracker's notificationHelper.ts). Kept as a standalone pure
/// function rather than a method on either class specifically to avoid a
/// circular import between the two.
///
/// 'project' intentionally has no specific-project deep link: the backend
/// trigger for project-assignment notifications (project.service.ts) never
/// threads a project id into the notification's data — only a human-
/// readable `projectTitle` string — so there's nothing to route to at the
/// per-project level yet. Falls back to the home screen (where the
/// employee's projects are listed) rather than a specific detail screen;
/// closing that gap for real is a backend change (adding a persisted
/// projectId), out of this phase's scope.
String? routeForNotificationCategory(String? category) {
  switch (category) {
    case 'leave':
      return AppRoute.leaveScreen;
    case 'payroll':
      return AppRoute.payRoleScreen;
    case 'project':
      return AppRoute.homeScreen;
    default:
      return null;
  }
}
