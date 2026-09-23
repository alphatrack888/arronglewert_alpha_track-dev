
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart';
import 'package:alpha_track/services/repository/project_repository/project_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';

enum LoadingStateProjectDetails { idle, loading, error }

class ProjectDetailsScreenController extends GetxController{
  final ProjectRepository _projectRepository = ProjectRepository();
  final Rxn<SingleProjectModel> singleProjectData = Rxn<SingleProjectModel>();
   final Rx<LoadingStateProjectDetails> apiLoadingState = LoadingStateProjectDetails.idle.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    String projectId = Get.arguments['projectId'];
    loadSingleProject(projectId);
  }


  Future<void> loadSingleProject(String projectId) async {
    try {
      apiLoadingState.value = LoadingStateProjectDetails.loading;

      final response = await _projectRepository.getSingleProject(projectId);

      if (response.statusCode == 200) {
        singleProjectData.value = response;
        appLog('Loaded single project: ${response.data?.title}');
      } else {
        AppSnackBar.error('Failed to load project details: ${response.message}');
      }
    } catch (e) {
      appLog('Error loading single project: $e');
      AppSnackBar.error('Error loading project details');
    } finally {
      apiLoadingState.value = LoadingStateProjectDetails.idle;
    }
  }
}