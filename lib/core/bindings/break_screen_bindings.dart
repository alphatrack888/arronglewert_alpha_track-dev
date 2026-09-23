import 'package:alpha_track/screens/break_screen/leave_screen/controller/leave_screen_controller.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';

class BreakScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveScreenController>((){
      appLog("Leave Screen Initialize");
      return LeaveScreenController();
    });
  }
}
