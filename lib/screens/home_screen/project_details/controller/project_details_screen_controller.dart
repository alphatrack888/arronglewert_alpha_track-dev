
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart';
import 'package:alpha_track/screens/home_screen/models/working_hours_summary_model.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_details_note_mapper.dart';
import 'package:alpha_track/services/repository/note_repository/note_repository.dart';
import 'package:alpha_track/services/repository/project_repository/project_repository.dart';
import 'package:alpha_track/services/repository/report_repository/report_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';

enum LoadingStateProjectDetails { idle, loading, error }

enum ProjectNotesLoadingState { idle, loading, error }

class ProjectDetailsScreenController extends GetxController {
  final ProjectRepository _projectRepository = ProjectRepository();
  final ReportRepository _reportRepository = ReportRepository();
  final NoteRepository _noteRepository = NoteRepository();
  final Rxn<SingleProjectModel> singleProjectData = Rxn<SingleProjectModel>();
  final Rx<LoadingStateProjectDetails> apiLoadingState =
      LoadingStateProjectDetails.idle.obs;
  RxBool isLoading = false.obs;

  final RxList<Map<String, String>> projectNotes = <Map<String, String>>[].obs;
  final Rx<ProjectNotesLoadingState> notesLoadingState =
      ProjectNotesLoadingState.idle.obs;

  String? currentProjectId;

  final Rxn<DailySummaryModel> dailySummaryData = Rxn<DailySummaryModel>();
  final Rxn<WorkingHoursSummaryModel> workingHoursSummary =
      Rxn<WorkingHoursSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['projectId'] is String) {
      currentProjectId = args['projectId'] as String;
    } else if (kDemoMode) {
      currentProjectId = 'demo_p1';
    } else {
      apiLoadingState.value = LoadingStateProjectDetails.error;
      AppSnackBar.error('projectIdNotFound'.tr);
      return;
    }

    final projectId = currentProjectId!;
    loadSingleProject(projectId);
    loadTimeData(projectId);
    loadProjectNotes(projectId);
  }

  Future<void> loadTimeData(String projectId) async {
    if (kDemoMode) {
      dailySummaryData.value = DemoData.dailySummary;
      workingHoursSummary.value = DemoData.workingHours;
      return;
    }
    try {
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final daily = await _reportRepository.fetchDailySummary(
        projectId: projectId,
        todayData: formattedDate,
      );
      if (daily.statusCode == 200) dailySummaryData.value = daily;

      final working = await _reportRepository.fetchWorkingHoursSummary(
        todayDate: formattedDate,
      );
      if (working.statusCode == 200) workingHoursSummary.value = working;
    } catch (e) {
      appLog('Error loading project time data: $e');
    }
  }

  Future<void> loadSingleProject(String projectId) async {
    if (kDemoMode) {
      singleProjectData.value = DemoData.singleProject(projectId);
      apiLoadingState.value = LoadingStateProjectDetails.idle;
      return;
    }
    try {
      apiLoadingState.value = LoadingStateProjectDetails.loading;

      final response = await _projectRepository.getSingleProject(projectId);

      if (response.statusCode == 200) {
        singleProjectData.value = response;
        appLog('Loaded single project: ${response.data?.title}');
      } else {
        apiLoadingState.value = LoadingStateProjectDetails.error;
        AppSnackBar.error('Failed to load project details: ${response.message}');
      }
    } catch (e) {
      appLog('Error loading single project: $e');
      apiLoadingState.value = LoadingStateProjectDetails.error;
      AppSnackBar.error('errLoadProjectDetails'.tr);
    } finally {
      if (apiLoadingState.value == LoadingStateProjectDetails.loading) {
        apiLoadingState.value = LoadingStateProjectDetails.idle;
      }
    }
  }

  Future<void> loadProjectNotes(String projectId) async {
    notesLoadingState.value = ProjectNotesLoadingState.loading;
    try {
      if (kDemoMode) {
        projectNotes.assignAll(DemoData.projectNotes);
        notesLoadingState.value = ProjectNotesLoadingState.idle;
        return;
      }

      final result = await _noteRepository.getAllNotes(projectId: projectId);
      if (result.success == true && result.data != null) {
        projectNotes.assignAll(
          ProjectDetailsNoteMapper.fromApiList(result.data!),
        );
        notesLoadingState.value = ProjectNotesLoadingState.idle;
      } else {
        projectNotes.clear();
        notesLoadingState.value = ProjectNotesLoadingState.error;
        appLog('Failed to load project notes: ${result.message}');
      }
    } catch (e) {
      appLog('Error loading project notes: $e');
      projectNotes.clear();
      notesLoadingState.value = ProjectNotesLoadingState.error;
    }
  }
}
