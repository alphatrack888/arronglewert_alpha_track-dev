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
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:alpha_track/services/stopwatch_service/stopwatch_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../services/repository/project_repository/project_repository.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';

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

  // Break state (demo): counts up while on a break.
  final RxInt _breakMilliseconds = 0.obs;
  Timer? _breakTimer;
  DateTime? breakStartedAt;

  // Whether the "Break Reminder" banner is currently shown. Snoozed via the
  // "Remind in 15 min" action; reset each time a new break starts.
  final RxBool reminderVisible = true.obs;

  /// Hide the break reminder banner ("Remind in 15 min").
  void snoozeReminder() {
    reminderVisible.value = false;
    AppSnackBar.customMessage(
      'remindAgain15'.tr,
      color: AppColors.mediumBlue,
    );
  }

  // Service instances
  final LocationService _locationService = LocationService.instance;
  final StorageServices _storageService = StorageServices.instance;
  final TimeTrackerRepository _timeTrackerRepository = TimeTrackerRepository();
  final ProjectRepository _projectRepository = ProjectRepository();
  final ReportRepository _reportRepository = ReportRepository();
  final StopwatchService _stopwatchService = StopwatchService();
  final AppSocketAllOperation _socket = AppSocketAllOperation.instance;
  String? _projectSocketUserId;

  // Function variable that can be overridden from UI
  Function()? showOneMinuteDialog;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    registerProjectSocketListeners();
  }

  /// Listens for assignment changes and refreshes the project list (Phase 2).
  void registerProjectSocketListeners() {
    final userId = _storageService.getUserId();
    if (userId.isEmpty) return;
    if (_projectSocketUserId == userId) return;
    _projectSocketUserId = userId;

    _socket.connectIfAuthenticated();
    _socket.readEvent(
      event: "newProject::$userId",
      handler: _handleProjectListSocketEvent,
    );
    _socket.readEvent(
      event: "removedProject::$userId",
      handler: _handleProjectListSocketEvent,
    );
  }

  void _handleProjectListSocketEvent(dynamic data) {
    appLog('Project socket event received, refreshing project list: $data');
    loadProjectList();
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
  bool get isOnBreak => _timerState.value == TimerState.paused;

  String get formattedBreakTime {
    final s = _breakMilliseconds.value ~/ 1000;
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(sec)}';
  }

  int get breakMinutes => _breakMilliseconds.value ~/ 60000;

  String get breakStartedLabel {
    final t = breakStartedAt;
    if (t == null) return '';
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '${'pausedAt'.tr} $hour12:${t.minute.toString().padLeft(2, '0')} $ampm';
  }
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
      return 'locationNotAvailable'.tr;
    }
    return '${currentLatitude.value.toStringAsFixed(6)}, ${currentLongitude.value.toStringAsFixed(6)}';
  }

  String get pauseResumeButtonText {
    if (isApiLoading) return 'loading'.tr;
    if (isStopped) return 'Start';
    if (isPaused) return 'Resume';
    return 'Pause';
  }

  // Current selected project info
  String get currentProjectTitle {
    if (_currentProjectId.value.isEmpty) return 'noProjectSelected'.tr;

    final projects = allProjectData.value?.data?.data;
    if (projects != null) {
      final currentProject = projects.firstWhereOrNull(
        (project) => project.id == _currentProjectId.value,
      );
      return currentProject?.title ?? 'unknownProject'.tr;
    }
    return selectedProjectTitle.value.isEmpty
        ? 'unknownProject'.tr
        : selectedProjectTitle.value;
  }

  // Company/team name of the currently selected project.
  String get currentProjectCompany {
    if (_currentProjectId.value.isEmpty) return '';
    final projects = allProjectData.value?.data?.data;
    final p = projects?.firstWhereOrNull(
      (project) => project.id == _currentProjectId.value,
    );
    return p?.company?.name ?? '';
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

      // Check and request location permission — skipped in demo/review builds
      // so a TestFlight tester or App Reviewer is never blocked by the location
      // prompt (demo data needs no real GPS).
      if (!kDemoMode) {
        _locationService.checkAndRequestLocationPermission();
      }

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
    // TEMPORARY demo mode — show sample projects without a backend/login.
    if (kDemoMode) {
      allProjectData.value = DemoData.projects;
      final first = DemoData.projects.data?.data?.first;
      if (first != null) {
        _currentProjectId.value = first.id ?? '';
        _currentCompanyId.value = first.company?.id ?? '';
        selectedProjectTitle.value = first.title ?? '';
      }
      projectLoadingState.value = LoadingState.idle;
      return;
    }
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
        'errLoadProjects'.tr,
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
      AppSnackBar.error('errLoadProjectDetails'.tr);
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

    // TEMPORARY demo mode — run the timer locally without location/backend.
    if (kDemoMode) {
      _currentSessionId.value = 'demo_session';
      _timerState.value = TimerState.running;
      _startTimer();
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
            'locationRequiredToStart'.tr,
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
          'locationUnable'.tr,
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
        AppSnackBar.error('timerStartFailed'.tr);
      }
    } catch (e) {
      appLog('Error starting timer: $e');
      AppSnackBar.error('timerStartError'.tr);
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  /// Show dialog when location permission is permanently denied
  Future<bool> _showPermissionDeniedDialog() async {
    return await DsDialog.confirm(
      title: 'locationPermissionRequired'.tr,
      message:
          'locationPermissionBody'.tr,
      confirmLabel: 'openSettings'.tr,
      cancelLabel: 'notNow'.tr,
      tone: DsDialogTone.warning,
      icon: LucideIcons.mapPin,
      destructive: false,
    );
  }

  Future<void> pause({bool isAutoPause = false}) async {
    if (_timerState.value != TimerState.running) {
      appLog('Timer is not running, cannot pause');
      return;
    }

    if (kDemoMode) {
      _timerState.value = TimerState.paused;
      _timer?.cancel();
      breakStartedAt = DateTime.now();
      reminderVisible.value = true;
      _breakMilliseconds.value = 0;
      _breakTimer?.cancel();
      _breakTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _breakMilliseconds.value += 1000;
      });
      if (isAutoPause) _showOneMinuteDialog();
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
          'locationUpdateFailedPause'.tr,
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

        AppSnackBar.success('timerPaused'.tr);
        appLog('Timer paused successfully via API');
      } else {
        AppSnackBar.error('timerPauseFailed'.tr);
      }
    } catch (e) {
      appLog('Error pausing timer: $e');
      AppSnackBar.error('timerPauseError'.tr);
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  Future<void> resume() async {
    if (_timerState.value != TimerState.paused) {
      appLog('Timer is not paused, cannot resume');
      return;
    }

    if (kDemoMode) {
      _breakTimer?.cancel();
      _breakMilliseconds.value = 0;
      breakStartedAt = null;
      _timerState.value = TimerState.running;
      _startTimer();
      return;
    }

    try {
      apiLoadingState.value = LoadingState.loading;

      // Get current location for resume event
      bool locationSuccess = await _getCurrentLocationForEvent('resume');
      if (!locationSuccess) {
        Get.snackbar(
          'Warning',
          'locationUpdateFailedResume'.tr,
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

        AppSnackBar.success('timerResumed'.tr);
        appLog('Timer resumed successfully via API');
      } else {
        AppSnackBar.error('timerResumeFailed'.tr);
      }
    } catch (e) {
      appLog('Error resuming timer: $e');
      AppSnackBar.error('timerResumeError'.tr);
    } finally {
      apiLoadingState.value = LoadingState.idle;
    }
  }

  Future<void> stop() async {
    if (kDemoMode) {
      _breakTimer?.cancel();
      _breakMilliseconds.value = 0;
      breakStartedAt = null;
      _resetTimer();
      return;
    }
    try {
      apiLoadingState.value = LoadingState.loading;

      // Get current location for stop event
      bool locationSuccess = await _getCurrentLocationForEvent('stop');
      if (!locationSuccess) {
        Get.snackbar(
          'Warning',
          'locationUpdateFailedStop'.tr,
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

        AppSnackBar.success('timerStopped'.tr);
        appLog('Timer stopped successfully via API');
      } else {
        AppSnackBar.error('timerStopFailed'.tr);
      }
    } catch (e) {
      appLog('Error stopping timer: $e');
      AppSnackBar.error('timerStopError'.tr);
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
      AppSnackBar.error('failedContinueTimer'.tr);
    }
  }

  Future<void> onBreakPressed() async {
    try {
      appLog('Break button pressed from hourly dialog');

      // Get location for break event
      await _getCurrentLocationForEvent('break');

      // Navigate to break screen
      // (Redesign: Break is no longer a bottom-nav tab, so route to it directly.)
      Get.toNamed(AppRoute.breakScreen);
    } catch (e) {
      appLog('Error on break pressed: $e');
      AppSnackBar.error('failedStartBreak'.tr);
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
      AppSnackBar.error('failedRefreshData'.tr);
    }
  }

  //! ==================== VALIDATION METHODS ====================

  bool _validateProjectSelection() {
    if (_currentProjectId.value.isEmpty) {
      AppSnackBar.error('selectProjectFirst'.tr);
      return false;
    }
    return true;
  }

  bool _validateSession() {
    if (_currentSessionId.value.isEmpty) {
      appLog('No session ID available for operation');
      AppSnackBar.error('noActiveSession'.tr);
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
            ? 'selectProjectToStart'.tr
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
    // TEMPORARY demo mode — populate report screens without a backend.
    if (kDemoMode) {
      breakHoursData.value = DemoData.breakHours;
      dailySummaryData.value = DemoData.dailySummary;
      workingHoursSummary.value = DemoData.workingHours;
      reportLoadingState.value = LoadingState.idle;
      return;
    }
    try {
      reportLoadingState.value = LoadingState.loading;

      // Format date as required by API (YYYY-MM-DD)
      String formattedDate =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      // Validate project selection
      if (_currentProjectId.value.isEmpty) {
        AppSnackBar.error('selectProjectFirst'.tr);
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
      AppSnackBar.error('failedLoadReport'.tr);
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
