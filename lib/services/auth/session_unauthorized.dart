import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:get/get.dart';

/// Route after session loss (401). Testable without GetX.
String routeForUnauthorized({required bool onboardComplete}) {
  return onboardComplete ? AppRoute.loginScreen : AppRoute.onboardingScreen;
}

/// Clears session and navigates once when the API returns 401.
class SessionUnauthorized {
  SessionUnauthorized._();

  static bool _handling = false;

  static Future<void> handle() async {
    if (_handling) return;
    _handling = true;
    try {
      AppSocketAllOperation.instance.disconnectAndClear();

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().profileData.value = null;
      }

      final storage = StorageServices.instance;
      await storage.rememberDeviceTokenForDeregister();
      await storage.storageClear();

      final route = routeForUnauthorized(onboardComplete: storage.getOnboardScreen());
      Get.offAllNamed(route);
    } finally {
      _handling = false;
    }
  }
}
