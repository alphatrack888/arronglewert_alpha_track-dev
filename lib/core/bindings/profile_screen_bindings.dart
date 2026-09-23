import 'package:alpha_track/screens/profile_screen/gallery_screen/controller/gallery_screen_controller.dart';
import 'package:alpha_track/screens/profile_screen/pay_role_screen/controller/payrole_screen_controller.dart';
import 'package:alpha_track/screens/profile_screen/personal_information/controller/personal_information_controller.dart';
import 'package:alpha_track/screens/profile_screen/settings_screen/change_pasword/controller/chanage_password_controller.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';

import '../../screens/profile_screen/language_screen/controller/language_screen_controller.dart';

class ProfileScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalInformationController>(() {
      appLog('Registering ProfileController');
      return PersonalInformationController();
    }, fenix: true);

    //! Gallery Screen
    Get.lazyPut<GalleryScreenController>(() {
      appLog("Gallery Screen Controller Registered");
      return GalleryScreenController();
    });

    //! Language Screen Controller
    Get.lazyPut<LanguageScreenController>(() {
      appLog("Language Screen Controller Registered");
      return LanguageScreenController();
    });

    //! Change Password Controller
    Get.lazyPut<ChanagePasswordController>(() {
      appLog("Change Password Controller Registered");
      return ChanagePasswordController();
    }, fenix: true);

    //! Payrole Screen
    Get.lazyPut<PayroleScreenController>(() {
      appLog("Payrole Screen Controller Registered");
      return PayroleScreenController();
    },fenix: true);
  }
}
