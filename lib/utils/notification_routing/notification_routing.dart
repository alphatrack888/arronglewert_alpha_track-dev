import 'package:alpha_track/core/app_route/app_route.dart';

/// Maps backend notification `category` to in-app routes (FCM tap + in-app list).
String? routeForNotificationCategory(String? category) {
  switch (category) {
    case 'leave':
      return AppRoute.leaveScheduleScreen;
    case 'payroll':
      return AppRoute.payRoleScreen;
    case 'project':
      return AppRoute.homeScreen;
    default:
      return null;
  }
}
