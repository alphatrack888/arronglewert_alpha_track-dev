import 'package:alpha_track/screens/home_screen/project_details/controller/project_details_screen_controller.dart';
import 'package:alpha_track/services/audio_palyer/controller/audio_controller.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';
import '../../screens/home_screen/main_home/controller/home_screen_controller.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenController>(() {
      appLog('Registering HomeScreenController');
      return HomeScreenController();
    });

    //! Project Details Screen Controller
    Get.lazyPut<ProjectDetailsScreenController>(() {
      appLog('Registering ProjectDetailsScreenController');
      return ProjectDetailsScreenController();
    }, fenix: true);

    //! Audio Screen Controller
     //! Audio Controller
    Get.lazyPut<AudioController>(() {
      appLog('Registering AudioController');
      return AudioController();
    }, fenix: true);
  }
}
