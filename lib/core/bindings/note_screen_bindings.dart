import 'package:alpha_track/screens/notes_screen/note_screen/controller/notes_screen_controller.dart';
import 'package:alpha_track/screens/notes_screen/notes_view/controller/note_veiw_controller.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';

class NoteScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteVeiwController>(() {
      appLog('Registering NoteVeiwController');
      return NoteVeiwController();
    }, fenix: true);

    //! Note Screen Controller
    Get.lazyPut<NotesScreenController>(() {
      appLog('Registering NotesScreenController');
      return NotesScreenController();
    }, fenix: true);
  }
}
