import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';

class NotificationRepository {
  ApiServices apiServices = ApiServices.instance;

  Future<NotificationGetModel> fetchAlltheNotificaton() async {
    try {
      final response = await apiServices.apiGetServices(ApiUrls.notification);
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
}
