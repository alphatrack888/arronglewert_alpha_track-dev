import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:alpha_track/screens/home_screen/models/all_project_models.dart';
import 'package:alpha_track/screens/notes_screen/notes_view/controller/note_veiw_controller.dart';
import 'package:alpha_track/services/repository/project_repository/project_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../widgets/app_snackbar/app_snackbar.dart';

class NotesScreenController extends GetxController {
  final ProjectRepository projectRepository = ProjectRepository();
  RxBool isLoading = false.obs;
  Rxn<AllProjectModel> allProjectData = Rxn<AllProjectModel>();
  final ImagePickerService _picker = ImagePickerService();
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Optionally load data on initialization
    // getAllProjectData();
  }

  Future<void> sendPhoto() async {
    try {
      final List<XFile> images = await _picker.pickMultipleImages();
      if (images.isNotEmpty) {
        selectedImages.assignAll(images);
      }
    } catch (e) {
      AppSnackBar.error(ImagePickerService.errorMessage(e));
    }
  }

  Future<void> sendSelectedImages() async {
    if (selectedImages.isNotEmpty) {
      // Get the NoteVeiwController instance to create images via API
      try {
        final noteController = Get.find<NoteVeiwController>();
        // Set selected images in note controller and call API method
        noteController.selectedImages.assignAll(selectedImages);
        await noteController.sendSelectedImages();
        selectedImages.clear();
      } catch (e) {
        appLog('💥 Error sending images: $e');
        AppSnackBar.error('Failed to create image note. Please try again.');
      }
    }
  }

  Future<void> getAllProjectData() async {
    try {
      isLoading(true);
      final response = await projectRepository.getAllProject();
      if (response.statusCode == 200) {
        allProjectData.value = response;
      } else {
        appLog(response.message ?? 'Error loading projects');
      }
    } catch (e) {
      appLog(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await getAllProjectData();
  }
  getProjectById(String projectId) {
    if (allProjectData.value?.data?.data != null) {
      return allProjectData.value!.data!.data!.firstWhere(
        (project) => project.id == projectId,
      );
    }
    return null;
  }
}
