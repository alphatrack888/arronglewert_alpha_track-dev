import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  void navigateToHomeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      String token = StorageServices.instance.getAccessToken();
      if (token.isNotEmpty) {
        appLog(
          "👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉👉 \n $token \n 👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈👈",
        );
        Get.offNamed(AppRoute.bottomNavigation);
        PushNotificationService.instance.onAuthenticatedNavigationReady();
        PushNotificationService.instance.refreshRegistrationIfNeeded();
      } else {
        appLog("No token found, navigating to Login Screen");
        Get.offNamed(AppRoute.onboardingScreen);
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    navigateToHomeScreen();
  }
}
