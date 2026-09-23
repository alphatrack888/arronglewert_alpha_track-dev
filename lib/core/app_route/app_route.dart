import 'package:alpha_track/core/bindings/break_screen_bindings.dart';
import 'package:alpha_track/core/bindings/home_screen_bindings.dart';
import 'package:alpha_track/core/bindings/note_screen_bindings.dart';
import 'package:alpha_track/core/bindings/profile_screen_bindings.dart';
import 'package:alpha_track/core/internet_middlewarechek/internet_middlewarecheck.dart';
import 'package:alpha_track/screens/auth_screen/forgot_password_screen/forgot_password_screen.dart';
import 'package:alpha_track/screens/auth_screen/login_screen/login_screen.dart';
import 'package:alpha_track/screens/auth_screen/otp_verificaiton_screen/otp_verification_screen.dart';
import 'package:alpha_track/screens/auth_screen/reset_password_screen/reset_password_screen.dart';
import 'package:alpha_track/screens/auth_screen/signup_screen/signup_screen.dart';
import 'package:alpha_track/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:alpha_track/screens/break_screen/break_screen/break_screen.dart';
import 'package:alpha_track/screens/break_screen/leave_screen/leave_screen.dart';
import 'package:alpha_track/screens/error_screen/erro_screen.dart';
import 'package:alpha_track/screens/home_screen/main_home/home_screen.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_details_screen.dart';
import 'package:alpha_track/screens/home_screen/projects_notes/project_notes_screen.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/note_screen.dart';
import 'package:alpha_track/screens/notes_screen/notes_view/note_view.dart';
import 'package:alpha_track/screens/notification_screen/notification_screen.dart';
import 'package:alpha_track/screens/onboarding_screen/onboarding_screen.dart';
import 'package:alpha_track/screens/onboarding_screen/onboarding_screen_final.dart';
import 'package:alpha_track/screens/onboarding_screen/onboarding_screen_two.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/gallery_screen.dart';
import 'package:alpha_track/screens/profile_screen/pay_role_screen/pay_role_screen.dart';
import 'package:alpha_track/screens/profile_screen/personal_information/personal_information.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/profile_screen.dart';
import 'package:alpha_track/screens/profile_screen/settings_screen/change_pasword/change_password_screen.dart';
import 'package:alpha_track/screens/profile_screen/settings_screen/privacy_policy/privacy_policy_screen.dart';
import 'package:alpha_track/screens/profile_screen/settings_screen/setting_screen.dart';
import 'package:alpha_track/screens/splash_screen/splash_screen.dart';
import 'package:get/get.dart';

import '../../screens/profile_screen/language_screen/language_screen.dart';

class AppRoute {
  AppRoute._();
  //! Auth and Onboarding Screen Routes
  static const String splashScreen = "/splashScreen";
  static const String onboardingScreen = "/onboardingScreen";
  static const String onboardingScreenTwo = "/onboardingScreenTwo";
  static const String onboardingScreenFinal = "/onboardingScreenFinal";
  static const String loginScreen = "/loginScreen";
  static const String signupScreen = "/signupScreen";
  static const String forgotPasswordScreen = "/forgotPasswordScreen";
  static const String otpVerificationScreen = "/otpVerificationScreen";

  static const String resetPasswordScreen = "/resetPasswordScreen";

  //! Error Screen Route
  static const String errorScreen = "/errorScreen";

  //! Home Screen Routes
  static const String bottomNavigation = "/bottomNavigation";
  static const String homeScreen = "/homeScreen";
  static const String projectDetailsScreen = "/projectDetailsScreen";
  static const String projectNoteScreen = "/projectNoteScreen";

  //! Break Screen Routes
  static const String breakScreen = "/breakScreen";
  static const String leaveScreen = "/leaveScreen";

  //! Notes Screen Routes
  static const String noteScreen = "/noteScreen";
  static const String noteView = "/noteView";

  //! Profile Screen Routes
  static const String profileScreen = "/profileScreen";
  static const String personalInformationScreen = "/personalInformationScreen";
  static const String editProfileInformation = "/editProfileInformation";
  static const String galleryScreen = "/galleryScreen";
  static const String languageScreen = "/languageScreen";
  static const String payRoleScreen = "/payRoleScreen";
  static const String settingScreen = "/settingScreen";
  static const String changePasswordScreen = "/changePasswordScreen";
  static const String privacyPolicyScreen = "/privacyPolicyScreen";

  //! Notificaiton Screen
  static const String notificationScreen = "/notificationScreen";

  //! Route Pages
  static List<GetPage> appRoutes = [
    //! Auth and Onboarding Screen Pages
    GetPage(
      name: AppRoute.splashScreen,
      page: () => const SplashScreen(),
      //binding: InitialBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoute.onboardingScreen,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoute.onboardingScreenTwo,
      page: () => OnboardingScreenTwo(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.onboardingScreenFinal,
      page: () => const OnboardingScreenFinal(),
      transition: Transition.rightToLeft,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.loginScreen,
      page: () => LoginScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.signupScreen,
      page: () => SignupScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.otpVerificationScreen,
      page: () => OtpVerificationScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.resetPasswordScreen,
      page: () => ResetPasswordScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    //! Error Screen Page
    GetPage(
      name: AppRoute.errorScreen,
      page: () => const ErrorScreen(),
      transition: Transition.rightToLeftWithFade,
    ),

    //! Home Screen Pages
    GetPage(
      name: AppRoute.bottomNavigation,
      page: () => BottomNavScreen(),
      binding: HomeScreenBinding(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.homeScreen,
      page: () => HomeScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.projectDetailsScreen,
      page: () => ProjectDetailsScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: HomeScreenBinding(),
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.projectNoteScreen,
      page: () => ProjectNotesScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),

    //! Break Screen Pages
    GetPage(
      name: AppRoute.breakScreen,
      page: () => BreakScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.leaveScreen,
      page: () => LeaveScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: BreakScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),

    //! Notes Screen Pages
    GetPage(
      name: AppRoute.noteScreen,
      page: () => NoteScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.noteView,
      page: () => NoteView(),
      transition: Transition.rightToLeftWithFade,
      binding: NoteScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),

    //! Profile Screen Pages
    GetPage(
      name: AppRoute.profileScreen,
      page: () => ProfileScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    // GetPage(
    //   name: AppRoute.profileScreenMain,
    //   page: () => ProfileScreenMain(),
    //   transition: Transition.rightToLeftWithFade,
    // ),
    GetPage(
      name: AppRoute.personalInformationScreen,
      page: () => PersonalInformation(),
      transition: Transition.rightToLeftWithFade,
      binding: ProfileScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.galleryScreen,
      page: () => GalleryScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: ProfileScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.languageScreen,
      page: () => LanguageScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: ProfileScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.payRoleScreen,
      page: () => PayRoleScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: ProfileScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.settingScreen,
      page: () => SettingScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.changePasswordScreen,
      page: () => ChangePasswordScreen(),
      transition: Transition.rightToLeftWithFade,
      binding: ProfileScreenBindings(),
      middlewares: [InternetCheckMiddleWare()],
    ),
    GetPage(
      name: AppRoute.privacyPolicyScreen,
      page: () => PrivacyPolicyScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),

    //! Notification Screen
    GetPage(
      name: AppRoute.notificationScreen,
      page: () => NotificationScreen(),
      transition: Transition.rightToLeftWithFade,
      middlewares: [InternetCheckMiddleWare()],
    ),
  ];
}
