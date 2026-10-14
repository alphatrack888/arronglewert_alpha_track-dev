import 'package:alpha_track/screens/home_screen/main_home/home_screen.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/profile_screen.dart';
import 'package:alpha_track/screens/projects_screen/projects_screen.dart';
import 'package:get/get.dart';

class BottomNavScreenController extends GetxController {
  var selectedIndex = 0.obs;

  // 2026 redesign: 3-tab bar — Home · Projects · Account.
  // (Notes now live inside a project; Break/Leave moved under Account.)
  final pages = [
    HomeScreen(),
    const ProjectsScreen(),
    ProfileScreen(),
  ];

  @override
  void onInit() {
    super.onInit();
    // Check if there are arguments passed for initial tab selection
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      final initialIndex = arguments['selectedIndex'];
      if (initialIndex != null && initialIndex is int) {
        selectedIndex.value = initialIndex;
      }
    }
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
