import 'package:alpha_track/screens/home_screen/main_home/controller/home_screen_controller.dart';
import 'package:alpha_track/screens/notification_screen/controller/notification_screen_controller.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/company_id_persistence.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';

/// Connect socket and re-register channel listeners after profile persists user id.
class EmployeeSocketSubscriptions {
  EmployeeSocketSubscriptions._();

  /// Loads profile id / company id when missing, then registers channels.
  static Future<void> primeUserIdFromProfileIfNeeded() async {
    if (kDemoMode) return;

    final storage = StorageServices.instance;
    final needsUserId = storage.getUserId().isEmpty;
    final needsCompanyId = storage.getCompanyId().isEmpty;

    if (!needsUserId && !needsCompanyId) {
      onUserIdReady();
      return;
    }

    try {
      final response = await ProfileRepository().getProfile();
      final id = response.data?.id;
      if (needsUserId && id != null && id.isNotEmpty) {
        await storage.setUserId(id);
      }
      await persistCompanyIdIfMissing(response.data?.company?.id);
      onUserIdReady();
    } catch (e) {
      appLog('primeUserIdFromProfileIfNeeded: $e');
      if (!needsUserId) {
        onUserIdReady();
      }
    }
  }

  /// Reconnect socket and re-register listeners after app returns to foreground.
  static void onAppResumed() {
    if (kDemoMode) return;

    final token = StorageServices.instance.getAccessToken();
    if (token.isEmpty) return;

    AppSocketAllOperation.instance.connectIfAuthenticated();
    onUserIdReady();
  }

  static void onUserIdReady() {
    AppSocketAllOperation.instance.connectIfAuthenticated();

    if (Get.isRegistered<HomeScreenController>()) {
      Get.find<HomeScreenController>().registerProjectSocketListeners();
    } else {
      appLog('Home socket listeners: HomeScreenController not registered yet');
    }

    if (Get.isRegistered<NotificationScreenController>()) {
      Get.find<NotificationScreenController>()
          .registerNotificationSocketListeners();
    } else {
      appLog(
        'Notification socket listeners: NotificationScreenController not registered yet',
      );
    }
  }
}
