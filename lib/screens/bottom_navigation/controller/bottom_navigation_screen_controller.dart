import 'package:alpha_track/screens/break_screen/break_screen/break_screen.dart';
import 'package:alpha_track/screens/home_screen/main_home/home_screen.dart';
import 'package:alpha_track/screens/notes_screen/note_screen/note_screen.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/profile_screen.dart';
import 'package:get/get.dart';

class BottomNavScreenController extends GetxController {
  var selectedIndex = 0.obs;
  final pages = [
    HomeScreen(),
    BreakScreen(),
    NoteScreen(),
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
