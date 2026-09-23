import 'package:alpha_track/screens/auth_screen/forgot_password_screen/controller/forgot_password_controller.dart';
import 'package:alpha_track/screens/auth_screen/login_screen/controller/login_screen_controller.dart';
import 'package:alpha_track/screens/auth_screen/otp_verificaiton_screen/controller/otp_verification_screen_controller.dart';
import 'package:alpha_track/screens/auth_screen/reset_password_screen/controller/reset_password_screen_controller.dart';
import 'package:alpha_track/screens/bottom_navigation/controller/bottom_navigation_screen_controller.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/controller/notes_screen_controller.dart';
import 'package:alpha_track/screens/notification_screen/controller/notification_screen_controller.dart';
import 'package:alpha_track/screens/splash_screen/controller/splash_screen_controller.dart';
import 'package:alpha_track/services/connectivity_services/connectivity_service.dart';
import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_text_field/controller/app_text_field_controller.dart';
import 'package:get/get.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';

import '../../screens/break_screen/break_screen/controller/break_screen_controller.dart';
import '../../screens/profile_screen/profile_screen_main/controller/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    //! Connectivity Service
    Get.lazyPut<ConnectivityService>(() {
      appLog('Registering ConnectivityService');
      return ConnectivityService();
    }, fenix: true);

    //! Storage Service
    Get.lazyPut<StorageServices>(() {
      appLog('Registering StorageServices');
      return StorageServices.instance;
    }, fenix: true);

    //! Auth Repository
    Get.lazyPut<AuthRepository>(() {
      appLog('Registering AuthRepository');
      return AuthRepository();
    }, fenix: true);

    //! Splash Screen Controller
    Get.lazyPut<SplashScreenController>(() {
      appLog('Registering SplashScreenController');
      return SplashScreenController();
    }, fenix: true);

    //! Login Screen Controller
    Get.lazyPut<LoginScreenController>(() {
      appLog('Registering LoginScreenController');
      return LoginScreenController();
    }, fenix: true);

    //! OTP Verification Screen Controller
    Get.lazyPut<OtpVerificationScreenController>(() {
      appLog('Registering OtpVerificationScreenController');
      return OtpVerificationScreenController();
    }, fenix: true);

    //! Forgot Password Controller
    Get.lazyPut<ForgotPasswordController>(() {
      appLog('Registering OtpVerificationScreenController');
      return ForgotPasswordController();
    }, fenix: true);

    //! Reset Password Controller
    Get.lazyPut<ResetPasswordScreenController>(() {
      appLog('Registering OtpVerificationScreenController');
      return ResetPasswordScreenController();
    }, fenix: true);

    //! Bottom Navigation Screen Controller
    Get.lazyPut<BottomNavScreenController>(() {
      appLog('Registering BottomNavScreenController');
      return BottomNavScreenController();
    }, fenix: true);

    //! App Text Field Controller
    Get.lazyPut<AppTextFieldController>(() {
      appLog('Registering AppTextFieldController');
      return AppTextFieldController();
    }, fenix: true);

    //! Profile Screen Controller
    Get.lazyPut<ProfileController>(() {
      appLog('Registering ProfileController');
      return ProfileController();
    }, fenix: true);

    //! Notes Screen Controller
    Get.lazyPut<NotesScreenController>(() {
      appLog('Registering NotesScreenController');
      return NotesScreenController();
    }, fenix: true);

    //! Break Screen Controller
    Get.lazyPut<BreakScreenController>(() {
      appLog('Registering BreakScreenController');
      return BreakScreenController();
    }, fenix: true);

    //! Notificaiton Screen Bindings
    Get.lazyPut<NotificationScreenController>(() {
      appLog("Regitering Notificaiton Screen Controller");
      return NotificationScreenController();
    },fenix: true);
  }
}
