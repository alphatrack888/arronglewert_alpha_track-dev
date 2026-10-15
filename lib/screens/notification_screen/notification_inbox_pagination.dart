import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';

/// Pure helpers for notification inbox pagination (unit-tested in P3).
class NotificationInboxPagination {
  NotificationInboxPagination._();

  /// Merges a fetched page into [existing]. Page 1 and refresh replace the list.
  static List<Datum> mergePageIntoList({
    required List<Datum> existing,
    required List<Datum> pageItems,
    required int page,
    required bool isRefresh,
  }) {
    if (isRefresh || page <= 1 || existing.isEmpty) {
      return List<Datum>.from(pageItems);
    }
    return [...existing, ...pageItems];
  }

  /// True when the user has scrolled near the bottom (infinite scroll).
  static bool shouldLoadMore({
    required double pixels,
    required double maxScrollExtent,
    double threshold = 200,
  }) {
    if (maxScrollExtent <= 0) return false;
    return pixels >= maxScrollExtent - threshold;
  }

  static String markReadPatchUrl(String markReadBase, String notificationId) {
    return '$markReadBase$notificationId';
  }
}
