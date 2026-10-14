import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/socket_service/employee_socket_subscriptions.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  void navigateToHomeScreen() {
    Future.delayed(const Duration(seconds: 3), () async {
      // TEMPORARY demo mode — jump straight to the main app (skip auth) so the
      // redesigned, populated screens can be reviewed without a login.
      if (kDemoMode) {
        Get.offNamed(AppRoute.bottomNavigation);
        return;
      }
      String token = StorageServices.instance.getAccessToken();
      if (token.isNotEmpty) {
        AppSocketAllOperation.instance.connectIfAuthenticated();
        await EmployeeSocketSubscriptions.primeUserIdFromProfileIfNeeded();
        Get.offNamed(AppRoute.bottomNavigation);
        PushNotificationService.instance.onAuthenticatedNavigationReady();
        await PushNotificationService.instance.refreshRegistrationIfNeeded();
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
