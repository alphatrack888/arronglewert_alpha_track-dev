import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/notification_preferences_screen/models/notification_preferences_model.dart';
import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';

class NotificationRepository {
  ApiServices apiServices = ApiServices.instance;

  Future<NotificationGetModel> fetchAlltheNotificaton({
    int page = 1,
    int limit = 20,
    String locale = 'english',
  }) async {
    try {
      final response = await apiServices.apiGetServices(
        '${ApiUrls.notification}?page=$page&limit=$limit&locale=${Uri.encodeQueryComponent(locale)}',
      );
      appLog("Raw API Response: $response");
      if (response != null) {
        final model = NotificationGetModel.fromJson(response);
        appLog("Parsed notifications count: ${model.data?.data?.length ?? 0}");
        return model;
      }
      return NotificationGetModel();
    } catch (e) {
      appLog("Notification parsing error: $e");
      appLog("Stack trace: ${StackTrace.current}");
      return NotificationGetModel();
    }
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      final response = await apiServices.apiPatchServices(
        url: '${ApiUrls.notificationMarkReadBase}$id',
      );
      return response != null;
    } catch (e) {
      appLog("markNotificationRead error: $e");
      return false;
    }
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      final response = await apiServices.apiPatchServices(
        url: ApiUrls.notificationMarkAllRead,
      );
      return response != null;
    } catch (e) {
      appLog("markAllNotificationsRead error: $e");
      return false;
    }
  }

  Future<NotificationPreferences?> getPreferences() async {
    try {
      final response = await apiServices.apiGetServices(
        ApiUrls.notificationPreferences,
      );
      if (response == null || response['data'] == null) return null;
      return NotificationPreferences.fromJson(
        response['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      appLog("getPreferences error: $e");
      return null;
    }
  }

  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    try {
      final response = await apiServices.apiPatchServices(
        url: ApiUrls.notificationPreferences,
        body: preferences.toJson(),
      );
      return response != null && response['success'] == true;
    } catch (e) {
      appLog("updatePreferences error: $e");
      return false;
    }
  }
}
