import 'dart:async';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/home_screen/models/all_project_models.dart';
import 'package:alpha_track/screens/home_screen/models/break_hours_model.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart';
import 'package:alpha_track/screens/home_screen/models/today_breaks_periods_model.dart';
import 'package:alpha_track/screens/home_screen/models/working_hours_summary_model.dart';
import 'package:alpha_track/services/location_services/location_services.dart';
import 'package:alpha_track/services/repository/report_repository/report_repository.dart';
import 'package:alpha_track/services/repository/time_tracker_repository/time_tracker_repository.dart';

import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/services/stopwatch_service/stopwatch_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../services/repository/project_repository/project_repository.dart';

enum TimerState { stopped, running, paused }

enum LoadingState { idle, loading, error }

class HomeScreenController extends GetxController with WidgetsBindingObserver {
  // Timer related variables
  Timer? _timer;
  final RxInt _elapsedMilliseconds = 0.obs;
  final Rx<TimerState> _timerState = TimerState.stopped.obs;
  final RxInt _lastDialogHour = 0.obs;
  final RxString _currentSessionId = ''.obs;
  final RxString _currentProjectId = ''.obs;
  final RxString _currentCompanyId = ''.obs;

  // UI state variables
  final RxBool isTodaySelected = true.obs;
  final Rx<LoadingState> apiLoadingState = LoadingState.idle.obs;
  final Rx<LoadingState> locationLoadingState = LoadingState.idle.obs;
  final Rx<LoadingState> projectLoadingState = LoadingState.idle.obs;

  // Location tracking
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;

  // Project data
  final Rxn<AllProjectModel> allProjectData = Rxn<AllProjectModel>();
  final Rxn<SingleProjectModel> singleProjectData = Rxn<SingleProjectModel>();
  final RxString selectedProjectTitle = ''.obs;

  // Service instances
  final LocationService _locationService = LocationService.instance;
  final StorageServices _storageService = StorageServices.instance;
  final TimeTrackerRepository _timeTrackerRepository = TimeTrackerRepository();
  final ProjectRepository _projectRepository = ProjectRepository();
  final ReportRepository _reportRepository = ReportRepository();
  final StopwatchService _stopwatchService = StopwatchService();

  // Function variable that can be overridden from UI
  Function()? showOneMinuteDialog;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    if (_currentProjectId.value.isNotEmpty) {
      // Save timer state for background time tracking
      _saveTimerStateForProject(_currentProjectId.value);
      appLog(
        'Timer state saved on app close for project: ${_currentProjectId.value}',
      );
      appLog('Timer was running: ${_timerState.value == TimerState.running}');
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App is going to background or being closed
        if (_currentProjectId.value.isNotEmpty) {
          _saveTimerStateForProject(_currentProjectId.value);
          appLog(
            'Timer state saved on app background for project: ${_currentProjectId.value}',
          );
          appLog(
            'Timer was running: ${_timerState.value == TimerState.running}',
          );
        }
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground
        if (_currentProjectId.value.isNotEmpty) {
          _loadTimerStateForProject(_currentProjectId.value);
          appLog(
            'Timer state loaded on app foreground for project: ${_currentProjectId.value}',
          );
        }
        break;
      case AppLifecycleState.inactive:
        // App is inactive but still visible (e.g., during a phone call)
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        break;
    }
  }

  //! ==================== GETTERS ====================

  Duration get elapsed => Duration(milliseconds: _elapsedMilliseconds.value);
  bool get isRunning => _timerState.value == TimerState.running;
  bool get isPaused => _timerState.value == TimerState.paused;
  bool get isStopped => _timerState.value == TimerState.stopped;
  String get currentSessionId => _currentSessionId.value;
  String get currentProjectId => _currentProjectId.value;
  String get currentCompanyId => _currentCompanyId.value;
  bool get isApiLoading => apiLoadingState.value == LoadingState.loading;
  bool get isLocationLoading =>
      locationLoadingState.value == LoadingState.loading;
  bool get isProjectLoading =>
      projectLoadingState.value == LoadingState.loading;

  String get formattedTime {
    final duration = Duration(milliseconds: _elapsedMilliseconds.value);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String get formattedLocation {
    if (currentLatitude.value == 0.0 && currentLongitude.value == 0.0) {
      return 'Location not available';
    }
    return '${currentLatitude.value.toStringAsFixed(6)}, ${currentLongitude.value.toStringAsFixed(6)}';
  }

  String get pauseResumeButtonText {
    if (isApiLoading) return 'Loading...';
    if (isStopped) return 'Start';
    if (isPaused) return 'Resume';
    return 'Pause';
  }

  // Current selected project info
  String get currentProjectTitle {
    if (_currentProjectId.value.isEmpty) return 'No project selected';

    final projects = allProjectData.value?.data?.data;
    if (projects != null) {
      final currentProject = projects.firstWhereOrNull(
        (project) => project.id == _currentProjectId.value,
      );
      return currentProject?.title ?? 'Unknown project';
    }
    return selectedProjectTitle.value.isEmpty
        ? 'Unknown project'
        : selectedProjectTitle.value;
  }

  //! ==================== INITIALIZATION ====================

  Future<void> _initializeApp() async {
    try {
      // Load saved data
      await _loadSavedData();

      // Load projects
      await loadProjectList();

      // Load saved location
      _loadSavedLocation();

      // Check and request location permission
      _locationService.checkAndRequestLocationPermission();

      // Load timer state for the current project
      if (_currentProjectId.value.isNotEmpty) {
        await _loadTimerStateForProject(_currentProjectId.value);
        // Initialize report data if project is selected
        await initializeReportData();
      } else {
        // if no project is selected, ensure timer is reset
        _resetTimer(clearPersistedState: false);
      }
      appLog('App initialized successfully');
      // Check the the user has enabled location services and request permission if needed
    } catch (e) {
      appLog('Error initializing app: $e');
    }
  }

  Future<void> _loadSavedData() async {
    try {
      _currentProjectId.value =
          _storageService.getData('current_project_id') ?? '';
      selectedProjectTitle.value =
          _storageService.getData('selected_project_title') ?? '';

      // Load the saved company ID
      _currentCompanyId.value = _storageService.getData('company_id') ?? '';

      appLog('Loaded saved data - Project ID: ${_currentProjectId.value}');
      appLog('Loaded saved company ID: ${_currentCompanyId.value}');
    } catch (e) {
      appLog('Error loading saved data: $e');
    }
  }

  //! ==================== PROJECT MANAGEMENT ====================
  Future<void> loadProjectList() async {
    try {
      projectLoadingState.value = LoadingState.loading;

      final response = await _projectRepository.getAllProject();

      if (response.statusCode == 200) {
        allProjectData.value = response;

        // Save company ID from the first project when projects are loaded
        if (response.data?.data?.isNotEmpty == true) {
          final firstProject = response.data!.data!.first;
          if (firstProject.company?.id != null) {
            _currentCompanyId.value = firstProject.company!.id!;
            await _storageService.setCompanyId(firstProject.company!.id!);
            appLog(
              'Company ID saved from first project: ${firstProject.company!.id}',
            );
          } else {
            appLog('No company ID found in first project');
          }
        }

        appLog('Loaded ${response.data?.data?.length ?? 0} projects');
      } else {
        projectLoadingState.value = LoadingState.error;
        AppSnackBar.error('Failed to load projects: ${response.message}');
      }
    } catch (e) {
      projectLoadingState.value = LoadingState.error;
      appLog('Error loading project list: $e');
      AppSnackBar.error(
        'Error loading projects. Please check your connection.',
      );
    } finally {
      if (projectLoadingState.value != LoadingState.error) {
        projectLoadingState.value = LoadingState.idle;
      }
    }
  }

  Future<void> loadSingleProject(String projectId) async {
    try {
      apiLoadingState.value = LoadingState.loading;

      final response = await _projectRepository.getSingleProject(projectId);

      if (response.statusCode == 200) {
        singleProjectData.value = response;
        appLog('Loaded single project: ${response.data?.title}');
      } else {
        AppSnackBar.error(
          'Failed to load project details: ${response.message}',
        );
      }
    } catch (e) {
      appLog('Error loading single project: $e');
      AppSnackBar.error('Error loading project details');
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  Future<void> setCurrentProjectId(
    String projectId, {
    String? projectTitle,
  }) async {
    try {
      if (_currentProjectId.value == projectId) return;

      // Set the new project ID
      _currentProjectId.value = projectId;
      await _storageService.saveData('current_project_id', projectId);

      if (projectTitle != null) {
        selectedProjectTitle.value = projectTitle;
        await _storageService.saveData('selected_project_title', projectTitle);
      }

      // Find the selected project and save its company ID
      final projects = allProjectData.value?.data?.data;
      if (projects != null) {
        final selectedProject = projects.firstWhereOrNull(
          (project) => project.id == projectId,
        );

        if (selectedProject?.company?.id != null) {
          _currentCompanyId.value = selectedProject!.company!.id!;
          await _storageService.setCompanyId(selectedProject.company!.id!);
          appLog(
            'Company ID saved for selected project: ${selectedProject.company!.id}',
          );
        } else {
          appLog('No company ID found for selected project');
        }
      }

      // Load the state for the new project
      await _loadTimerStateForProject(projectId);

      // Fetch project details
      await loadSingleProject(projectId);

      // Initialize report data for the selected project
      await initializeReportData();

      appLog('Project selected: $projectId - $projectTitle');

      // Show success message
      if (projectTitle != null) {
        AppSnackBar.customMessage(
          'Timer will track time for: $projectTitle',
          color: AppColors.mediumBlue,
        );
      }
    } catch (e) {
      appLog('Error setting project ID: $e');
    }
  }

  void gototheDetailsPage() {
    appLog('Navigating to project details page');
    appLog("Details page project ID: ${_currentProjectId.value}");
    Get.toNamed(
      AppRoute.projectDetailsScreen,
      arguments: {"projectId": _currentProjectId.value},
    );
  }

  void setSessionId(String sessionId) {
    try {
      _currentSessionId.value = sessionId;
      // Save session ID for the current project
      if (_currentProjectId.value.isNotEmpty) {
        _storageService.saveData(
          _sessionKey(_currentProjectId.value),
          sessionId,
        );
        appLog(
          'Session ID set for project ${_currentProjectId.value}: $sessionId',
        );
      }
    } catch (e) {
      appLog('Error setting session ID: $e');
    }
  }

  //! ==================== LOCATION MANAGEMENT ====================

  void _loadSavedLocation() {
    try {
      final savedLocation = _storageService.getCurrentLocation();
      if (savedLocation != null) {
        currentLatitude.value = savedLocation['latitude'];
        currentLongitude.value = savedLocation['longitude'];
        appLog(
          'Loaded saved location: ${currentLatitude.value}, ${currentLongitude.value}',
        );
      } else {
        appLog('No saved location found');
      }
    } catch (e) {
      appLog('Error loading saved location: $e');
    }
  }

  Future<bool> _getCurrentLocationForEvent(String eventType) async {
    try {
      locationLoadingState.value = LoadingState.loading;
      appLog('Getting location for event: $eventType');

      Position? position = await _locationService.getCurrentLocationWithRetry();

      if (position != null) {
        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;

        // Save to storage
        await _storageService.saveCurrentLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        // Save to work session history
        await _storageService.saveWorkSessionLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          sessionType: eventType,
        );

        appLog(
          'Location updated for $eventType: ${position.latitude}, ${position.longitude}',
        );
        locationLoadingState.value = LoadingState.idle;
        return true;
      } else {
        locationLoadingState.value = LoadingState.error;
        appLog('Failed to get location for $eventType');
        return false;
      }
    } catch (e) {
      locationLoadingState.value = LoadingState.error;
      appLog('Error getting location for $eventType: $e');
      return false;
    }
  }

  Future<void> refreshLocation() async {
    final success = await _getCurrentLocationForEvent('manual_refresh');
    if (success) {
      Get.snackbar(
        'Location Updated',
        'Current location: $formattedLocation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.blue50,
        colorText: AppColors.black500,
        duration: const Duration(seconds: 2),
      );
    } else {
      AppSnackBar.error('Failed to update location');
    }
  }

  //! ==================== TIMER PERSISTENCE (PROJECT-SPECIFIC) ====================

  String _sessionKey(String projectId) => 'session_id_$projectId';
  String _elapsedMsKey(String projectId) => 'elapsed_ms_$projectId';
  String _timerStateKey(String projectId) => 'timer_state_$projectId';

  Future<void> _loadTimerStateForProject(String projectId) async {
    try {
      appLog('Loading timer state for project: $projectId');
      if (projectId.isEmpty) {
        _resetTimer(clearPersistedState: false); // Don't clear if no project
        return;
      }

      //! Stop any currently running timer before loading new state
      _timer?.cancel();

      // Load stopwatch data using the service (includes background time calculation)
      final stopwatchData = await _stopwatchService.loadStopwatchData(
        projectId,
      );

      final stateStr =
          _storageService.getData(_timerStateKey(projectId)) ??
          'TimerState.stopped';
      final sessionId = _storageService.getData(_sessionKey(projectId)) ?? '';

      // Use the adjusted elapsed time from stopwatch service (includes background time)
      _elapsedMilliseconds.value = stopwatchData['elapsedMs'] ?? 0;
      _currentSessionId.value = sessionId;

      // Determine timer state - if it was running when app closed, keep it running
      if (stopwatchData['wasRunning'] == true) {
        _timerState.value = TimerState.running;
      } else {
        _timerState.value = TimerState.values.firstWhere(
          (e) => e.toString() == stateStr,
          orElse: () => TimerState.stopped,
        );
      }

      // Reset the last dialog hour based on current elapsed time
      _lastDialogHour.value = (_elapsedMilliseconds.value / 3600000).floor();

      appLog('Loaded state for project $projectId: ${timerStatusText}');
      appLog('Background time calculated: ${stopwatchData['elapsedMs']} ms');

      if (_timerState.value == TimerState.running) {
        _startTimer();
      }
    } catch (e) {
      appLog('Error loading timer state for project $projectId: $e');
      _resetTimer(
        clearPersistedState: false,
      ); // Reset to a clean state on error
    }
  }

  Future<void> _saveTimerStateForProject(String projectId) async {
    try {
      if (projectId.isEmpty) return;

      // Save using stopwatch service for proper background time tracking
      await _stopwatchService.saveStopwatchData(
        elapsedMs: _elapsedMilliseconds.value,
        isRunning: _timerState.value == TimerState.running,
        sessionId: projectId,
      );

      // Also save to regular storage for compatibility
      await _storageService.saveData(
        _elapsedMsKey(projectId),
        _elapsedMilliseconds.value,
      );
      await _storageService.saveData(
        _timerStateKey(projectId),
        _timerState.value.toString(),
      );
      await _storageService.saveData(
        _sessionKey(projectId),
        _currentSessionId.value,
      );

      appLog('Saved timer state for project $projectId');
    } catch (e) {
      appLog('Error saving timer state for project $projectId: $e');
    }
  }

  //! ==================== TIMER CONTROL ====================

  Future<void> start() async {
    if (_timerState.value != TimerState.stopped) {
      appLog('Timer already running or paused');
      return;
    }

    try {
      apiLoadingState.value = LoadingState.loading;

      // Validate project selection
      if (!_validateProjectSelection()) {
        apiLoadingState.value = LoadingState.idle;
        return;
      }

      // Ensure company ID is saved for the current project
      await _ensureCompanyIdIsSaved();

      // Check location permission before proceeding
      LocationPermission permission = await Geolocator.checkPermission();
      appLog('Current location permission: $permission');

      // If permission is permanently denied, show dialog with Settings link
      if (permission == LocationPermission.deniedForever) {
        apiLoadingState.value = LoadingState.idle;
        appLog('Location permission permanently denied, showing dialog...');

        // Show dialog to user with option to open settings
        bool shouldOpenSettings = await _showPermissionDeniedDialog();
        if (shouldOpenSettings) {
          await Geolocator.openAppSettings();
        }
        return;
      }

      // If permission is denied, request it (shows native permission dialog)
      if (permission == LocationPermission.denied) {
        appLog('Location permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          apiLoadingState.value = LoadingState.idle;
          AppSnackBar.error(
            'Location permission is required to start the timer.',
          );
          appLog('Location permission denied by user');
          return;
        }

        // If still denied after request, it's now permanently denied
        if (permission == LocationPermission.deniedForever) {
          apiLoadingState.value = LoadingState.idle;
          bool shouldOpenSettings = await _showPermissionDeniedDialog();
          if (shouldOpenSettings) {
            await Geolocator.openAppSettings();
          }
          return;
        }
      }

      // Check if location services are enabled
      if (!await _locationService.isLocationServiceEnabled()) {
        apiLoadingState.value = LoadingState.idle;
        appLog('Location services disabled, prompting user...');
        await _locationService.checkAndRequestLocationPermission();
        return;
      }

      // Get current location for start event
      bool locationSuccess = await _getCurrentLocationForEvent('start');
      if (!locationSuccess) {
        apiLoadingState.value = LoadingState.idle;
        AppSnackBar.error(
          'Unable to get your location. Please check your location settings.',
        );
        return;
      }

      // Call API to start timer
      String? sessionId = await _timeTrackerRepository.startTimer(
        projectID: _currentProjectId.value,
        lat: currentLatitude.value,
        lng: currentLongitude.value,
      );

      if (sessionId != null) {
        _timerState.value = TimerState.running;
        setSessionId(sessionId);
        _startTimer();
        await _saveTimerStateForProject(_currentProjectId.value);

        AppSnackBar.success('Timer started for: $currentProjectTitle');
        appLog('Timer started successfully with session ID: $sessionId');
        appLog('Company ID for running timer: ${_currentCompanyId.value}');
      } else {
        AppSnackBar.error('Failed to start timer. Please try again.');
      }
    } catch (e) {
      appLog('Error starting timer: $e');
      AppSnackBar.error('An error occurred while starting timer');
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  /// Show dialog when location permission is permanently denied
  Future<bool> _showPermissionDeniedDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: AppColors.white100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.location_off, color: AppColors.red, size: 28),
                Gap(width: AppSize.width(value: 10)),
                Expanded(
                  child: AppText(
                    text: 'Location Permission Required',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black500,
                  ),
                ),
              ],
            ),
            content: AppText(
              text:
                  'To track your work time, we need access to your location. You can enable this in Settings.',
              fontSize: 14,
              color: AppColors.black400,
              maxLines: 5,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: AppText(
                  text: 'Not Now',
                  fontSize: 14,
                  color: AppColors.black400,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Get.back(result: true),
                child: AppText(
                  text: 'Open Settings',
                  fontSize: 14,
                  color: AppColors.white100,
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  Future<void> pause({bool isAutoPause = false}) async {
    if (_timerState.value != TimerState.running) {
      appLog('Timer is not running, cannot pause');
      return;
    }

    try {
      apiLoadingState.value = LoadingState.loading;

      // Get current location for pause event
      bool locationSuccess = await _getCurrentLocationForEvent(
        isAutoPause ? 'auto_pause_hourly' : 'pause',
      );
      if (!locationSuccess) {
        Get.snackbar(
          'Warning',
          'Location update failed, but timer will be paused.',
        );
      }

      // Validate session ID
      if (!_validateSession()) return;

      // Call API to pause timer
      bool success = await _timeTrackerRepository.pauseTimer(
        sessionID: _currentSessionId.value,
        lat: currentLatitude.value,
        lng: currentLongitude.value,
      );

      if (success) {
        _timerState.value = TimerState.paused;
        _timer?.cancel();
        await _saveTimerStateForProject(_currentProjectId.value);

        if (isAutoPause) {
          _showOneMinuteDialog();
        }

        AppSnackBar.success('Timer paused');
        appLog('Timer paused successfully via API');
      } else {
        AppSnackBar.error('Failed to pause timer. Please try again.');
      }
    } catch (e) {
      appLog('Error pausing timer: $e');
      AppSnackBar.error('An error occurred while pausing timer');
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  Future<void> resume() async {
    if (_timerState.value != TimerState.paused) {
      appLog('Timer is not paused, cannot resume');
      return;
    }

    try {
      apiLoadingState.value = LoadingState.loading;

      // Get current location for resume event
      bool locationSuccess = await _getCurrentLocationForEvent('resume');
      if (!locationSuccess) {
        Get.snackbar(
          'Warning',
          'Location update failed, but timer will be resumed.',
        );
      }

      // Validate session ID
      if (!_validateSession()) return;

      // Call API to resume timer
      bool success = await _timeTrackerRepository.resumeTimer(
        sessionID: _currentSessionId.value,
        lat: currentLatitude.value,
        lng: currentLongitude.value,
      );

      if (success) {
        _timerState.value = TimerState.running;
        _startTimer();
        await _saveTimerStateForProject(_currentProjectId.value);

        AppSnackBar.success('Timer resumed');
        appLog('Timer resumed successfully via API');
      } else {
        AppSnackBar.error('Failed to resume timer. Please try again.');
      }
    } catch (e) {
      appLog('Error resuming timer: $e');
      AppSnackBar.error('An error occurred while resuming timer');
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  Future<void> stop() async {
    try {
      apiLoadingState.value = LoadingState.loading;

      // Get current location for stop event
      bool locationSuccess = await _getCurrentLocationForEvent('stop');
      if (!locationSuccess) {
        Get.snackbar(
          'Warning',
          'Location update failed, but timer will be stopped.',
        );
      }

      // Call API to stop timer
      bool success = await _timeTrackerRepository.stopTimer(
        lat: currentLatitude.value,
        lng: currentLongitude.value,
        sessionID: _currentSessionId.value,
      );

      if (success) {
        _resetTimer();

        AppSnackBar.success('Timer stopped and reset');
        appLog('Timer stopped successfully via API');
      } else {
        AppSnackBar.error('Failed to stop timer. Please try again.');
      }
    } catch (e) {
      appLog('Error stopping timer: $e');
      AppSnackBar.error('An error occurred while stopping timer');
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  //! ==================== TIMER INTERNAL METHODS ====================

  void _startTimer() {
    // Cancel any existing timer to prevent multiple timers
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedMilliseconds.value += 1000;

      // Check if a new hour has passed for auto-pause
      int currentHour = (_elapsedMilliseconds.value / 3600000).floor();
      if (currentHour > _lastDialogHour.value && currentHour > 0) {
        _lastDialogHour.value = currentHour;
        appLog('Auto-pause triggered at hour: $currentHour');

        // Auto-pause and show dialog
        pause(isAutoPause: true);
      }
    });
  }

  void _resetTimer({bool clearPersistedState = true}) {
    _timer?.cancel();
    _timerState.value = TimerState.stopped;
    _elapsedMilliseconds.value = 0;
    _lastDialogHour.value = 0;
    _currentSessionId.value = '';

    if (clearPersistedState && _currentProjectId.value.isNotEmpty) {
      appLog("Clearing persisted state for project ${_currentProjectId.value}");
      // Clear stopwatch service data
      _stopwatchService.clearStopwatchData(_currentProjectId.value);
      // This effectively clears the project's saved state by saving the reset values.
      _saveTimerStateForProject(_currentProjectId.value);
    }
  }

  void _showOneMinuteDialog() {
    if (showOneMinuteDialog != null) {
      showOneMinuteDialog!();
    }
  }

  //! ==================== TIMER BUTTON HANDLERS ====================

  void togglePauseResume() {
    if (isApiLoading) return;
    if (isStopped) {
      start();
    } else if (isPaused) {
      resume();
    } else if (isRunning) {
      pause();
    }
  }

  void toggleStartReset() {
    if (isApiLoading) return;
    if (isStopped && _elapsedMilliseconds.value == 0) {
      start();
    } else {
      stop();
    }
  }

  //! ==================== DIALOG HANDLERS ====================

  Future<void> onContinuePressed() async {
    try {
      appLog('Continue button pressed from hourly dialog');
      await resume();
    } catch (e) {
      appLog('Error on continue pressed: $e');
      AppSnackBar.error('Failed to continue timer');
    }
  }

  Future<void> onBreakPressed() async {
    try {
      appLog('Break button pressed from hourly dialog');

      // Get location for break event
      await _getCurrentLocationForEvent('break');

      // Navigate to break screen
      Get.toNamed(AppRoute.bottomNavigation, arguments: {'selectedIndex': 1});
    } catch (e) {
      appLog('Error on break pressed: $e');
      AppSnackBar.error('Failed to start break');
    }
  }

  //! ==================== UI STATE MANAGEMENT ====================

  void selectToday() {
    isTodaySelected.value = true;
    appLog('Today tab selected');
  }

  void selectReport() {
    isTodaySelected.value = false;
    appLog('Report tab selected');
  }

  //! ==================== DATA REFRESH ====================

  Future<void> refreshData() async {
    try {
      await Future.wait([loadProjectList(), refreshLocation()]);

      AppSnackBar.success('Data refreshed successfully');
    } catch (e) {
      appLog('Error refreshing data: $e');
      AppSnackBar.error('Failed to refresh data');
    }
  }

  //! ==================== VALIDATION METHODS ====================

  bool _validateProjectSelection() {
    if (_currentProjectId.value.isEmpty) {
      AppSnackBar.error('Please select a project first');
      return false;
    }
    return true;
  }

  bool _validateSession() {
    if (_currentSessionId.value.isEmpty) {
      appLog('No session ID available for operation');
      AppSnackBar.error('No active session found');
      return false;
    }
    return true;
  }

  //! ==================== COMPUTED PROPERTIES ====================

  // Check if a project is currently selected
  bool isProjectSelected(String projectId) {
    return _currentProjectId.value == projectId;
  }

  // Get current timer status for display
  String get timerStatusText {
    switch (_timerState.value) {
      case TimerState.running:
        return 'Running - $currentProjectTitle';
      case TimerState.paused:
        return 'Paused - $currentProjectTitle';
      case TimerState.stopped:
        return _currentProjectId.value.isEmpty
            ? 'Select a project to start'
            : 'Ready to start - $currentProjectTitle';
    }
  }

  // Ensure company ID is saved for the current project
  Future<void> _ensureCompanyIdIsSaved() async {
    try {
      if (_currentCompanyId.value.isEmpty &&
          _currentProjectId.value.isNotEmpty) {
        final projects = allProjectData.value?.data?.data;
        if (projects != null) {
          final selectedProject = projects.firstWhereOrNull(
            (project) => project.id == _currentProjectId.value,
          );

          if (selectedProject?.company?.id != null) {
            _currentCompanyId.value = selectedProject!.company!.id!;
            await _storageService.setCompanyId(selectedProject.company!.id!);
            appLog('Company ID ensured: ${selectedProject.company!.id}');
          }
        }
      }
    } catch (e) {
      appLog('Error ensuring company ID is saved: $e');
    }
  }

  // Add this method to get company ID for debugging
  String getCurrentCompanyId() {
    return _currentCompanyId.value;
  }

  // ! This Section is for report section
  // Report related variables
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rxn<BreakHoursModel> breakHoursData = Rxn<BreakHoursModel>();
  final Rxn<DailySummaryModel> dailySummaryData = Rxn<DailySummaryModel>();
  final Rxn<WorkingHoursSummaryModel> workingHoursSummary =
      Rxn<WorkingHoursSummaryModel>();
  final Rxn<TodayBreakPeriodsModel> todayBreakPeriods =
      Rxn<TodayBreakPeriodsModel>();

  final Rx<LoadingState> reportLoadingState = LoadingState.idle.obs;

  Future<void> loadReportData() async {
    try {
      reportLoadingState.value = LoadingState.loading;

      // Format date as required by API (YYYY-MM-DD)
      String formattedDate =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      // Validate project selection
      if (_currentProjectId.value.isEmpty) {
        AppSnackBar.error('Please select a project first');
        return;
      }

      // Load break hours data for bar chart
      final breakHoursResponse = await _reportRepository.fetchBreakHoursByDay();
      if (breakHoursResponse.statusCode == 200) {
        breakHoursData.value = breakHoursResponse;
      }

      // Load daily summary data
      final dailySummaryResponse = await _reportRepository.fetchDailySummary(
        projectId: _currentProjectId.value,
        todayData: formattedDate,
      );
      if (dailySummaryResponse.statusCode == 200) {
        dailySummaryData.value = dailySummaryResponse;
      }

      // Load working hours summary
      final workingHoursResponse = await _reportRepository
          .fetchWorkingHoursSummary(todayDate: formattedDate);
      if (workingHoursResponse.statusCode == 200) {
        workingHoursSummary.value = workingHoursResponse;
      }

      // Load today's break periods
      final breakPeriodsResponse = await _reportRepository
          .fetchTodayBreakPeriods(todayDate: formattedDate);
      if (breakPeriodsResponse.statusCode == 200) {
        todayBreakPeriods.value = breakPeriodsResponse;
      }

      appLog('Report data loaded successfully for date: $formattedDate');
    } catch (e) {
      appLog('Error loading report data: $e');
      AppSnackBar.error('Failed to load report data');
    } finally {
      reportLoadingState.value = LoadingState.idle;
    }
  }

  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
    loadReportData(); // Reload data for new date
  }

  // Convert break hours data to bar chart format
  List<double> getBarChartData() {
    if (breakHoursData.value?.data == null) {
      return [0, 0, 0, 0, 0, 0, 0]; // Default values for 7 days
    }

    final data = breakHoursData.value!.data!;
    // Order matches the visual layout: Sat, Sun, Mon, Tue, Wed, Thu, Fri
    return [
      (data.sat ?? 0).toDouble(),
      (data.sun ?? 0).toDouble(),
      (data.mon ?? 0).toDouble(),
      (data.tue ?? 0).toDouble(),
      (data.wed ?? 0).toDouble(),
      (data.thu ?? 0).toDouble(),
      (data.fri ?? 0).toDouble(),
    ];
  }

  // Initialize report data on app start
  Future<void> initializeReportData() async {
    // Set initial date to today
    selectedDate.value = DateTime.now();
    // Load initial report data
    await loadReportData();
  }
}
