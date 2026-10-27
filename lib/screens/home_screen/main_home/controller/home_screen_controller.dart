import 'dart:async';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/home_screen/project_details/controller/project_details_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';
import 'package:alpha_track/screens/report_screen/report_period.dart';
import 'package:alpha_track/screens/home_screen/models/all_project_models.dart';
import 'package:alpha_track/screens/home_screen/models/break_hours_model.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart';
import 'package:alpha_track/screens/home_screen/models/today_breaks_periods_model.dart';
import 'package:alpha_track/screens/home_screen/models/working_hours_summary_model.dart';
import 'package:alpha_track/services/break_preference/break_preference_service.dart';
import 'package:alpha_track/services/location_services/location_services.dart';
import 'package:alpha_track/services/repository/report_repository/report_repository.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/repository/time_tracker_repository/time_tracker_repository.dart';
import 'package:alpha_track/services/repository/time_tracker_repository/timer_start_errors.dart';

import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
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
import 'package:alpha_track/services/socket_service/socket_channel_names.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';

enum TimerState { stopped, running, paused }

enum LoadingState { idle, loading, error }

/// Location waits that run before a timer request. The request itself uses
/// [LoadingState] on the button.
enum StartPreparePhase { idle, checkingLocation, readingLocation }

/// Which timer control is waiting on GPS or its request.
enum TimerActionWait { idle, takeBreak, resume, stop }

class HomeScreenController extends GetxController with WidgetsBindingObserver {
  // Timer related variables
  Timer? _timer;
  final RxInt _elapsedMilliseconds = 0.obs;
  final Rx<TimerState> _timerState = TimerState.stopped.obs;
  final RxInt _lastDialogHour = 0.obs;
  final RxString _currentSessionId = ''.obs;
  final RxString _currentProjectId = ''.obs;
  final RxString _currentCompanyId = ''.obs;

  /// The project that owns the open session. Kept apart from the project on
  /// screen, because opening another project reloads that project's stopped clock.
  final RxString _openSessionProjectId = ''.obs;
  final RxString _openSessionProjectTitle = ''.obs;
  bool _openSessionDialogVisible = false;

  /// Covers location and the start request so a second tap is ignored
  /// without turning on the Start spinner.
  bool _startInProgress = false;

  /// Location wait shown on the wide buttons. Idle during the API call.
  final Rx<StartPreparePhase> startPreparePhase = StartPreparePhase.idle.obs;

  /// Break, resume, or stop while that control is waiting. Idle during Start.
  final Rx<TimerActionWait> timerActionWait = TimerActionWait.idle.obs;

  /// Project whose list control spins for this start. Empty when idle.
  final RxString startingProjectId = ''.obs;

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

  // Break clock. Counts from the pause instant while a session is paused.
  final RxInt _breakMilliseconds = 0.obs;
  Timer? _breakTimer;
  DateTime? breakStartedAt;
  String? _breakProjectId;
  DateTime? _reminderSnoozeUntil;
  DateTime? _dismissedBreakStart;

  static const Duration _breakReminderDelay = Duration(minutes: 15);

  // Shown only after the open pause has lasted [_breakReminderDelay].
  final RxBool reminderVisible = false.obs;

  /// Hide the break reminder for 15 minutes. It returns if the pause is still open.
  void snoozeReminder() {
    _reminderSnoozeUntil = DateTime.now().add(_breakReminderDelay);
    reminderVisible.value = false;
    AppSnackBar.customMessage(
      'remindAgain15'.tr,
      color: AppColors.mediumBlue,
    );
  }

  /// Hide the reminder for this pause. Does not resume work.
  void dismissBreakReminder() {
    _dismissedBreakStart = breakStartedAt;
    reminderVisible.value = false;
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
      event: SocketChannelNames.newProjectChannel(userId),
      handler: _handleProjectListSocketEvent,
    );
    _socket.readEvent(
      event: SocketChannelNames.removedProjectChannel(userId),
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
    _breakTimer?.cancel();
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

  /// Project id of the session that is still running or paused. Empty when none.
  String get openSessionProjectId => _openSessionProjectId.value;

  /// True when [projectId] is not the project that already has an open session.
  bool isStartBlockedFor(String projectId) {
    final openId = _openSessionProjectId.value;
    return openId.isNotEmpty && openId != projectId;
  }
  bool get isOnBreak => _timerState.value == TimerState.paused;

  String get formattedBreakTime {
    final ms = _breakMilliseconds.value;
    if (breakStartedAt == null) return '';
    final s = ms ~/ 1000;
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(sec)}';
  }

  int get breakMinutes => _breakMilliseconds.value ~/ 60000;

  String get breakStartedLabel {
    final t = breakStartedAt?.toLocal();
    if (t == null) return '';
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '${'pausedAt'.tr} $hour12:${t.minute.toString().padLeft(2, '0')} $ampm';
  }
  String get currentSessionId => _currentSessionId.value;
  String get currentProjectId => _currentProjectId.value;
  String get currentCompanyId => _currentCompanyId.value;
  bool get isApiLoading => apiLoadingState.value == LoadingState.loading;

  /// True while this start is waiting on location or the timer request.
  bool isStartingProject(String projectId) {
    if (projectId.isEmpty || startingProjectId.value != projectId) return false;
    return startPreparePhase.value != StartPreparePhase.idle || isApiLoading;
  }

  /// Label key for the wide Start button during a location wait. Null during
  /// the timer request, which keeps the wave-dots loader.
  String? get startPrepareLabelKey {
    if (timerActionWait.value != TimerActionWait.idle) return null;
    switch (startPreparePhase.value) {
      case StartPreparePhase.checkingLocation:
        return 'checkingLocation';
      case StartPreparePhase.readingLocation:
        return 'readingLocation';
      case StartPreparePhase.idle:
        return null;
    }
  }

  /// Location label for the wide break or stop button that is waiting.
  String? locationLabelFor(TimerActionWait action) {
    if (timerActionWait.value != action) return null;
    if (startPreparePhase.value != StartPreparePhase.readingLocation) {
      return null;
    }
    return 'readingLocation';
  }

  /// True while [action] is reading location or calling its request.
  bool isTimerActionBusy(TimerActionWait action) {
    if (timerActionWait.value != action) return false;
    return startPreparePhase.value == StartPreparePhase.readingLocation ||
        isApiLoading;
  }

  bool get isAnyTimerActionBusy =>
      timerActionWait.value != TimerActionWait.idle;
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

      // The server is the source of truth for a session left open. A reinstall
      // or a missed stop has no local timer, so adopt that session before
      // falling back to storage.
      if (!kDemoMode && await _restoreOpenSessionFromServer(loadReport: true)) {
        appLog('Restored open session from server');
        return;
      }

      // A fresh install has no saved project. Selecting one here loads its
      // timer state and report, so that work is not repeated below.
      final selectedFresh = await _ensureCurrentProject();
      if (!selectedFresh && _currentProjectId.value.isNotEmpty) {
        await _loadTimerStateForProject(_currentProjectId.value);
        await initializeReportData();
      } else if (_currentProjectId.value.isEmpty) {
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
  Future<void> loadProjectList({bool keepVisible = false}) async {
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
    final hasProjects = allProjectData.value?.data?.data?.isNotEmpty == true;
    final quiet = keepVisible && hasProjects;
    try {
      if (!quiet) projectLoadingState.value = LoadingState.loading;

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
      } else if (!quiet) {
        projectLoadingState.value = LoadingState.error;
        AppSnackBar.error('Failed to load projects: ${response.message}');
      } else {
        appLog('Quiet project reload failed: ${response.statusCode} ${response.message}');
      }
    } catch (e) {
      appLog('Error loading project list: $e');
      if (!quiet) {
        projectLoadingState.value = LoadingState.error;
        AppSnackBar.error(
          'errLoadProjects'.tr,
        );
      }
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
    bool announce = true,
    bool loadDetails = true,
  }) async {
    try {
      if (projectId.isEmpty) return;
      final openId = _openSessionProjectId.value;
      if (openId.isNotEmpty && openId != projectId) return;
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

      // Details and the home summary stay put when the user only selects
      // a project from the list. Loading them spins Start and clears the
      // today total while the home screen is still visible.
      if (loadDetails) {
        await loadSingleProject(projectId);
        await initializeReportData();
      }

      appLog('Project selected: $projectId - $projectTitle');

      // Show success message
      if (announce && projectTitle != null) {
        AppSnackBar.customMessage(
          'Timer will track time for: $projectTitle',
          color: AppColors.mediumBlue,
        );
      }
    } catch (e) {
      appLog('Error setting project ID: $e');
    }
  }

  void gototheDetailsPage([String? projectId]) {
    final id = (projectId != null && projectId.isNotEmpty)
        ? projectId
        : _currentProjectId.value;
    appLog('Navigating to project details page');
    appLog('Details page project ID: $id');
    Get.toNamed(
      AppRoute.projectDetailsScreen,
      arguments: {"projectId": id},
    );
  }

  /// Marks [projectId] as the project Start will use, without opening it
  /// or reloading the home summary. Does nothing while another session is open.
  Future<void> selectProjectForTracking(
    String projectId, {
    String? projectTitle,
  }) {
    return setCurrentProjectId(
      projectId,
      projectTitle: projectTitle,
      announce: false,
      loadDetails: false,
    );
  }

  /// The ring/check is shown when nothing is open, and on the open project itself.
  bool showsSelectFor(String projectId) {
    final open = _openSessionProjectId.value;
    if (open.isEmpty) return true;
    return open == projectId;
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
  String _breakStartedKey(String projectId) => 'break_started_at_$projectId';

  DateTime? _savedBreakStart(String projectId) {
    if (projectId.isEmpty) return null;
    final raw = _storageService.getData(_breakStartedKey(projectId));
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _loadTimerStateForProject(String projectId) async {
    try {
      appLog('Loading timer state for project: $projectId');
      if (projectId.isEmpty) {
        _resetTimer(clearPersistedState: false); // Don't clear if no project
        return;
      }

      //! Stop any currently running timer before loading new state
      _timer?.cancel();
      final savedBreakStart = _savedBreakStart(projectId);
      final keepBreak = _breakProjectId == projectId && breakStartedAt != null;
      if (!keepBreak) {
        _endBreak(clearStored: _breakProjectId != projectId);
      }

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

      // Determine timer state - if it was running when app closed, keep it running.
      // Assigned after the break start so a restored pause paints with its length.
      final TimerState loadedState;
      if (stopwatchData['wasRunning'] == true) {
        loadedState = TimerState.running;
      } else {
        loadedState = TimerState.values.firstWhere(
          (e) => e.toString() == stateStr,
          orElse: () => TimerState.stopped,
        );
      }

      // Reset the last dialog hour based on current elapsed time
      _lastDialogHour.value = (_elapsedMilliseconds.value / 3600000).floor();

      appLog('Background time calculated: ${stopwatchData['elapsedMs']} ms');

      if (loadedState == TimerState.running) {
        _endBreak();
        await _storageService.saveData(_breakStartedKey(projectId), '');
        _timerState.value = TimerState.running;
        _startTimer();
      } else if (loadedState == TimerState.paused &&
          keepBreak &&
          breakStartedAt != null) {
        _timerState.value = TimerState.paused;
        _syncBreakClock();
        _startBreakClock();
      } else if (loadedState == TimerState.paused && savedBreakStart != null) {
        _beginBreak(savedBreakStart);
        _timerState.value = TimerState.paused;
        _syncBreakReminder();
      } else {
        _endBreak();
        await _storageService.saveData(_breakStartedKey(projectId), '');
        _timerState.value = loadedState;
      }
      appLog('Loaded state for project $projectId: ${timerStatusText}');
      if (_timerState.value != TimerState.stopped) {
        _rememberOpenSession(projectId, _titleForProject(projectId));
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
    if (isApiLoading ||
        _openSessionDialogVisible ||
        _startInProgress ||
        isAnyTimerActionBusy) {
      return;
    }
    if (_openSessionProjectId.value.isNotEmpty &&
        _openSessionProjectId.value != _currentProjectId.value) {
      await _warnOpenSessionElsewhere();
      return;
    }
    if (_timerState.value != TimerState.stopped) {
      appLog('Timer already running or paused');
      AppSnackBar.error('timerAlreadyActive'.tr);
      return;
    }

    // TEMPORARY demo mode — run the timer locally without location/backend.
    if (kDemoMode) {
      _currentSessionId.value = 'demo_session';
      _timerState.value = TimerState.running;
      _rememberOpenSession(_currentProjectId.value, currentProjectTitle);
      _startTimer();
      _refreshProjectTimeList();
      return;
    }

    _startInProgress = true;
    startingProjectId.value = _currentProjectId.value;
    try {
      await _ensureCurrentProject(loadDetails: false);
      if (!_validateProjectSelection()) return;
      startingProjectId.value = _currentProjectId.value;

      if (!isEmployeeRoleForTimer(_storageService.getUserRole())) {
        AppSnackBar.error('timerStartEmployeeOnly'.tr);
        return;
      }

      await _ensureCompanyIdIsSaved();
      if (!await _prepareStartLocation()) return;

      try {
        apiLoadingState.value = LoadingState.loading;
        startPreparePhase.value = StartPreparePhase.idle;
        final startResult = await _timeTrackerRepository.startTimer(
          projectID: _currentProjectId.value,
          lat: currentLatitude.value,
          lng: currentLongitude.value,
        );

        if (startResult.success && startResult.data != null) {
          final sessionId = startResult.data!;
          _timerState.value = TimerState.running;
          setSessionId(sessionId);
          _rememberOpenSession(_currentProjectId.value, currentProjectTitle);
          _startTimer();
          await _saveTimerStateForProject(_currentProjectId.value);

          _announceStartSuccess();
          appLog('Timer started successfully with session ID: $sessionId');
          appLog('Company ID for running timer: ${_currentCompanyId.value}');
          _refreshProjectTimeList();
        } else if (startResult.statusCode == 409) {
          await _restoreOpenSessionFromServer();
          AppSnackBar.error('sessionStillOpen'.tr);
        } else if (startResult.kind == ApiFailureKind.timeout) {
          final adopted = await _restoreOpenSessionFromServer();
          if (adopted) {
            _announceStartSuccess();
          } else {
            AppSnackBar.error('timerStartTimeout'.tr);
          }
        } else {
          AppSnackBar.error(timerStartFailureMessage(startResult));
        }
      } catch (e) {
        appLog('Error starting timer: $e');
        AppSnackBar.error('timerStartError'.tr);
      } finally {
        apiLoadingState.value = LoadingState.idle;
      }
    } catch (e) {
      appLog('Error preparing start: $e');
      AppSnackBar.error('timerStartError'.tr);
    } finally {
      _startInProgress = false;
      startPreparePhase.value = StartPreparePhase.idle;
      startingProjectId.value = '';
    }
  }

  void _announceStartSuccess() {
    AppSnackBar.success('Timer started for: $currentProjectTitle');
  }

  /// Permission, location services, and a GPS fix. The Start spinner stays off.
  /// Returns false after the user has been told why tracking cannot start.
  Future<bool> _prepareStartLocation() async {
    startPreparePhase.value = StartPreparePhase.checkingLocation;
    LocationPermission permission = await Geolocator.checkPermission();
    appLog('Current location permission: $permission');

    if (permission == LocationPermission.deniedForever) {
      appLog('Location permission permanently denied, showing dialog...');
      final shouldOpenSettings = await _showPermissionDeniedDialog();
      if (shouldOpenSettings) {
        await Geolocator.openAppSettings();
      }
      return false;
    }

    if (permission == LocationPermission.denied) {
      appLog('Location permission denied, requesting permission...');
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        AppSnackBar.error('locationRequiredToStart'.tr);
        appLog('Location permission denied by user');
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        final shouldOpenSettings = await _showPermissionDeniedDialog();
        if (shouldOpenSettings) {
          await Geolocator.openAppSettings();
        }
        return false;
      }
    }

    if (!await _locationService.isLocationServiceEnabled()) {
      appLog('Location services disabled, prompting user...');
      await _locationService.checkAndRequestLocationPermission();
      if (!await _locationService.isLocationServiceEnabled()) {
        AppSnackBar.error('locationServicesDisabledBody'.tr);
      }
      return false;
    }

    startPreparePhase.value = StartPreparePhase.readingLocation;
    AppSnackBar.message(
      'readingLocation'.tr,
      duration: const Duration(seconds: 60),
    );
    final locationSuccess = await _getCurrentLocationForEvent('start');
    if (!locationSuccess) {
      AppSnackBar.error('locationUnable'.tr);
      return false;
    }
    return true;
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
    if (isApiLoading || isAnyTimerActionBusy) return;
    if (_timerState.value != TimerState.running) {
      appLog('Timer is not running, cannot pause');
      return;
    }

    if (kDemoMode) {
      _freezeWorkClock();
      _beginBreak(DateTime.now());
      _timerState.value = TimerState.paused;
      _syncBreakReminder();
      if (isAutoPause) _showOneMinuteDialog();
      return;
    }

    final workWasRunning = _freezeWorkClock();
    var committed = false;
    timerActionWait.value = TimerActionWait.takeBreak;
    try {
      startPreparePhase.value = StartPreparePhase.readingLocation;
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

      apiLoadingState.value = LoadingState.loading;
      startPreparePhase.value = StartPreparePhase.idle;
      bool success = false;
      DateTime? pauseStartedAt;
      final outcome = await _timeTrackerRepository.pauseTimer(
        sessionID: _currentSessionId.value,
        lat: currentLatitude.value,
        lng: currentLongitude.value,
      );
      success = outcome.ok;
      pauseStartedAt = outcome.pauseStartedAt;

      if (success) {
        committed = true;
        if (pauseStartedAt != null) {
          _beginBreak(pauseStartedAt);
        } else {
          _endBreak();
        }
        _timerState.value = TimerState.paused;
        _syncBreakReminder();
        await _saveTimerStateForProject(_currentProjectId.value);

        if (isAutoPause) {
          _showOneMinuteDialog();
        }

        AppSnackBar.success('timerPaused'.tr);
        appLog('Timer paused successfully via API');
        await loadProjectList(keepVisible: true);
      } else {
        AppSnackBar.error('timerPauseFailed'.tr);
      }
    } catch (e) {
      appLog('Error pausing timer: $e');
      AppSnackBar.error('timerPauseError'.tr);
    } finally {
      if (!committed &&
          workWasRunning &&
          _timerState.value == TimerState.running) {
        _startTimer();
      }
      apiLoadingState.value = LoadingState.idle;
      startPreparePhase.value = StartPreparePhase.idle;
      timerActionWait.value = TimerActionWait.idle;
    }
  }

  Future<void> resume() async {
    if (isApiLoading || isAnyTimerActionBusy) return;
    if (_timerState.value != TimerState.paused) {
      appLog('Timer is not paused, cannot resume');
      return;
    }

    if (kDemoMode) {
      _endBreak();
      _timerState.value = TimerState.running;
      _startTimer();
      return;
    }

    final breakWasRunning = _freezeBreakClock();
    var committed = false;
    timerActionWait.value = TimerActionWait.resume;
    try {
      startPreparePhase.value = StartPreparePhase.readingLocation;
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
      apiLoadingState.value = LoadingState.loading;
      startPreparePhase.value = StartPreparePhase.idle;
      bool success = await _timeTrackerRepository.resumeTimer(
        sessionID: _currentSessionId.value,
        lat: currentLatitude.value,
        lng: currentLongitude.value,
      );

      if (success) {
        committed = true;
        _endBreak();
        _timerState.value = TimerState.running;
        _startTimer();
        await _saveTimerStateForProject(_currentProjectId.value);
        unawaited(loadTodayBreaks());

        AppSnackBar.success('timerResumed'.tr);
        appLog('Timer resumed successfully via API');
      } else {
        AppSnackBar.error('timerResumeFailed'.tr);
      }
    } catch (e) {
      appLog('Error resuming timer: $e');
      AppSnackBar.error('timerResumeError'.tr);
    } finally {
      if (!committed &&
          breakWasRunning &&
          _timerState.value == TimerState.paused) {
        _startBreakClock();
      }
      apiLoadingState.value = LoadingState.idle;
      startPreparePhase.value = StartPreparePhase.idle;
      timerActionWait.value = TimerActionWait.idle;
    }
  }

  Future<void> stop() async {
    if (isApiLoading || isAnyTimerActionBusy) return;
    if (kDemoMode) {
      _endBreak();
      _resetTimer();
      _clearOpenSession();
      _refreshProjectTimeList();
      return;
    }

    final wasRunning = _timerState.value == TimerState.running;
    final wasPaused = _timerState.value == TimerState.paused;
    final workWasRunning = wasRunning && _freezeWorkClock();
    final breakWasRunning = wasPaused && _freezeBreakClock();
    var committed = false;
    timerActionWait.value = TimerActionWait.stop;
    try {
      startPreparePhase.value = StartPreparePhase.readingLocation;
      // Get current location for stop event
      bool locationSuccess = await _getCurrentLocationForEvent('stop');
      if (!locationSuccess) {
        Get.snackbar(
          'Warning',
          'locationUpdateFailedStop'.tr,
        );
      }

      // Call API to stop timer
      apiLoadingState.value = LoadingState.loading;
      startPreparePhase.value = StartPreparePhase.idle;
      bool success = await _timeTrackerRepository.stopTimer(
        lat: currentLatitude.value,
        lng: currentLongitude.value,
        sessionID: _currentSessionId.value,
      );

      if (success) {
        committed = true;
        _resetTimer();
        _clearOpenSession();

        AppSnackBar.success('timerStopped'.tr);
        appLog('Timer stopped successfully via API');
        _refreshProjectTimeList();
        await loadProjectList(keepVisible: true);
      } else {
        AppSnackBar.error('timerStopFailed'.tr);
      }
    } catch (e) {
      appLog('Error stopping timer: $e');
      AppSnackBar.error('timerStopError'.tr);
    } finally {
      if (!committed) {
        if (workWasRunning && _timerState.value == TimerState.running) {
          _startTimer();
        }
        if (breakWasRunning && _timerState.value == TimerState.paused) {
          _startBreakClock();
        }
      }
      apiLoadingState.value = LoadingState.idle;
      startPreparePhase.value = StartPreparePhase.idle;
      timerActionWait.value = TimerActionWait.idle;
    }
  }

  //! ==================== TIMER INTERNAL METHODS ====================

  bool _isAutomaticBreakEnabled() {
    if (!Get.isRegistered<BreakPreferenceService>()) {
      return BreakPreferenceService.defaultAutomaticBreakEnabled;
    }
    return Get.find<BreakPreferenceService>().automaticBreakEnabled;
  }

  /// Stops the work clock without changing the session state.
  /// Returns whether it was ticking.
  bool _freezeWorkClock() {
    final active = _timer?.isActive ?? false;
    _timer?.cancel();
    _timer = null;
    return active;
  }

  /// Stops the break clock without changing the session state.
  /// Returns whether it was ticking.
  bool _freezeBreakClock() {
    final active = _breakTimer?.isActive ?? false;
    _breakTimer?.cancel();
    _breakTimer = null;
    return active;
  }

  void _startBreakClock() {
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncBreakClock();
    });
  }

  void _beginBreak(DateTime startedAt) {
    breakStartedAt = startedAt;
    _breakProjectId = _currentProjectId.value;
    _reminderSnoozeUntil = null;
    _dismissedBreakStart = null;
    reminderVisible.value = false;
    final projectId = _breakProjectId;
    if (projectId != null && projectId.isNotEmpty) {
      unawaited(
        _storageService.saveData(
          _breakStartedKey(projectId),
          startedAt.toIso8601String(),
        ),
      );
    }
    _syncBreakClock();
    _startBreakClock();
    unawaited(loadTodayBreaks());
  }

  void _endBreak({bool clearStored = true}) {
    final projectId = _breakProjectId;
    _breakTimer?.cancel();
    _breakTimer = null;
    _breakMilliseconds.value = 0;
    breakStartedAt = null;
    _breakProjectId = null;
    _reminderSnoozeUntil = null;
    _dismissedBreakStart = null;
    reminderVisible.value = false;
    if (clearStored && projectId != null && projectId.isNotEmpty) {
      unawaited(_storageService.saveData(_breakStartedKey(projectId), ''));
    }
  }

  void _syncBreakClock() {
    final start = breakStartedAt;
    if (start == null) {
      _breakMilliseconds.value = 0;
      reminderVisible.value = false;
      return;
    }
    final elapsed = DateTime.now().difference(start);
    _breakMilliseconds.value = elapsed.isNegative ? 0 : elapsed.inMilliseconds;
    _syncBreakReminder();
  }

  void _syncBreakReminder() {
    final start = breakStartedAt;
    if (start == null || _timerState.value != TimerState.paused) {
      reminderVisible.value = false;
      return;
    }
    final snoozed = _reminderSnoozeUntil != null &&
        DateTime.now().isBefore(_reminderSnoozeUntil!);
    final dismissed = _dismissedBreakStart == start;
    reminderVisible.value =
        breakMinutes >= _breakReminderDelay.inMinutes && !snoozed && !dismissed;
  }

  /// Finished pauses for the UTC day stored on the session.
  Future<void> loadTodayBreaks() async {
    if (kDemoMode) {
      todayBreakPeriods.value = null;
      return;
    }
    try {
      final response = await _reportRepository.fetchTodayBreakPeriods(
        todayDate: utcDateKey(),
      );
      if (response.success == true) {
        todayBreakPeriods.value = response;
      } else {
        todayBreakPeriods.value = null;
      }
    } catch (e) {
      appLog('Error loading today breaks: $e');
      todayBreakPeriods.value = null;
    }
  }

  void _startTimer() {
    // Cancel any existing timer to prevent multiple timers
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedMilliseconds.value += 1000;

      // Check if a new hour has passed for auto-pause
      int currentHour = (_elapsedMilliseconds.value / 3600000).floor();
      if (currentHour > _lastDialogHour.value && currentHour > 0) {
        _lastDialogHour.value = currentHour;
        if (!_isAutomaticBreakEnabled()) {
          appLog('Auto-pause skipped at hour $currentHour (automatic break off)');
          return;
        }
        appLog('Auto-pause triggered at hour: $currentHour');

        // Auto-pause and show dialog
        pause(isAutoPause: true);
      }
    });
  }

  /// Revalidate Project Details Time Tracker list after timer mutations.
  void _refreshProjectTimeList() {
    if (!Get.isRegistered<ProjectDetailsScreenController>()) return;
    final c = Get.find<ProjectDetailsScreenController>();
    final id = c.currentProjectId;
    if (id != null && id == _currentProjectId.value) {
      unawaited(c.loadTimeData(id));
    }
  }

  void _resetTimer({bool clearPersistedState = true}) {
    _timer?.cancel();
    _timer = null;
    _endBreak();
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
    if (isApiLoading || _openSessionDialogVisible) return;
    if (_openSessionProjectId.value.isNotEmpty &&
        _openSessionProjectId.value != _currentProjectId.value) {
      _warnOpenSessionElsewhere();
      return;
    }
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

  /// Shows the oldest server session that is still active or paused.
  /// Returns false when there is nothing to adopt, including a failed fetch,
  /// so the caller can keep the locally saved timer.
  Future<bool> _restoreOpenSessionFromServer({bool loadReport = false}) async {
    final sessions = await _timeTrackerRepository.getOpenSessions();
    if (sessions == null || sessions.isEmpty) return false;

    final session = sessions.first;
    final projectId = session.projectId;
    final breakProjectId = (projectId != null && projectId.isNotEmpty)
        ? projectId
        : _currentProjectId.value;
    final savedBreakStart = _savedBreakStart(breakProjectId);
    final switching = projectId != null &&
        projectId.isNotEmpty &&
        projectId != _currentProjectId.value;
    if (switching) {
      await setCurrentProjectId(
        projectId,
        projectTitle: session.projectTitle,
        announce: false,
      );
    } else if (session.projectTitle != null &&
        session.projectTitle!.isNotEmpty &&
        selectedProjectTitle.value.isEmpty) {
      selectedProjectTitle.value = session.projectTitle!;
      await _storageService.saveData(
        'selected_project_title',
        session.projectTitle,
      );
    }

    await _applyServerSession(session, savedBreakStart);
    if (loadReport && !switching && _currentProjectId.value.isNotEmpty) {
      await initializeReportData();
    }
    return true;
  }

  Future<void> _applyServerSession(
    OpenTimeSession session,
    DateTime? savedBreakStart,
  ) async {
    final breakProjectId = (session.projectId != null &&
            session.projectId!.isNotEmpty)
        ? session.projectId!
        : _currentProjectId.value;
    _timer?.cancel();
    _timer = null;
    _endBreak(clearStored: false);
    final elapsed = session.elapsedMs < 0 ? 0 : session.elapsedMs;
    _elapsedMilliseconds.value = elapsed;
    _lastDialogHour.value = (elapsed / 3600000).floor();
    _currentSessionId.value = session.id;
    if (session.status == 'paused') {
      final startedAt = session.pauseStartedAt ?? savedBreakStart;
      if (startedAt != null) {
        _beginBreak(startedAt);
      } else if (breakProjectId.isNotEmpty) {
        unawaited(_storageService.saveData(_breakStartedKey(breakProjectId), ''));
      }
      _timerState.value = TimerState.paused;
      _syncBreakReminder();
    } else {
      _endBreak();
      if (breakProjectId.isNotEmpty) {
        unawaited(_storageService.saveData(_breakStartedKey(breakProjectId), ''));
      }
      _timerState.value = TimerState.running;
      _startTimer();
    }
    _rememberOpenSession(
      session.projectId ?? _currentProjectId.value,
      session.projectTitle ?? selectedProjectTitle.value,
    );
    if (_currentProjectId.value.isNotEmpty) {
      await _saveTimerStateForProject(_currentProjectId.value);
    }
  }

  void _rememberOpenSession(String projectId, String? title) {
    if (projectId.isEmpty) return;
    _openSessionProjectId.value = projectId;
    final trimmed = title?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      _openSessionProjectTitle.value = trimmed;
      return;
    }
    final known = _titleForProject(projectId);
    if (known.isNotEmpty) _openSessionProjectTitle.value = known;
  }

  void _clearOpenSession() {
    _openSessionProjectId.value = '';
    _openSessionProjectTitle.value = '';
  }

  String _titleForProject(String projectId) {
    final projects = allProjectData.value?.data?.data;
    final match = projects?.firstWhereOrNull((project) => project.id == projectId);
    final fromList = match?.title?.trim() ?? '';
    if (fromList.isNotEmpty) return fromList;
    if (_currentProjectId.value == projectId) {
      return selectedProjectTitle.value.trim();
    }
    return '';
  }

  String _openSessionLabel() {
    final name = _openSessionProjectTitle.value.trim();
    if (name.isNotEmpty) return name;
    return 'thisProject'.tr;
  }

  Widget _openSessionMessage(String name) {
    final base = AppTextStyles.subtitle.copyWith(height: 1.45);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: 'sessionOpenElsewhereBefore'.tr),
          TextSpan(
            text: name,
            style: base.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: 'sessionOpenElsewhereAfter'.tr),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Names the open project and can take the user back to it. Does not stop
  /// the session or change the selected project when dismissed.
  Future<void> _warnOpenSessionElsewhere() async {
    if (_openSessionDialogVisible) return;
    _openSessionDialogVisible = true;
    final name = _openSessionLabel();
    try {
      final go = await DsDialog.confirm(
        title: 'sessionOpenElsewhereTitle'.tr,
        content: _openSessionMessage(name),
        confirmLabel: 'goToOpenProject'.trParams({'project': name}),
        cancelLabel: 'notNow'.tr,
        tone: DsDialogTone.warning,
        destructive: false,
      );
      if (!go) return;
      final openId = _openSessionProjectId.value;
      if (openId.isEmpty) return;
      final title = _openSessionProjectTitle.value.trim();
      await setCurrentProjectId(
        openId,
        projectTitle: title.isEmpty ? null : title,
        announce: false,
      );
      if (Get.currentRoute == AppRoute.projectDetailsScreen &&
          Get.isRegistered<ProjectDetailsScreenController>()) {
        Get.find<ProjectDetailsScreenController>().syncProject(openId);
      } else {
        gototheDetailsPage();
      }
    } finally {
      _openSessionDialogVisible = false;
    }
  }

  /// Starts [projectId], or warns when another project already has an open session.
  /// Tapping the project that owns the open session only selects it again.
  Future<void> requestStartForProject(
    String projectId, {
    String? projectTitle,
  }) async {
    if (projectId.isEmpty ||
        isApiLoading ||
        _openSessionDialogVisible ||
        _startInProgress ||
        isAnyTimerActionBusy) {
      return;
    }
    final openId = _openSessionProjectId.value;
    if (openId.isNotEmpty && openId != projectId) {
      await _warnOpenSessionElsewhere();
      return;
    }
    if (openId.isNotEmpty) {
      if (_currentProjectId.value != projectId) {
        await setCurrentProjectId(
          projectId,
          projectTitle: projectTitle,
          announce: false,
          loadDetails: false,
        );
      }
      return;
    }
    if (_currentProjectId.value != projectId) {
      await setCurrentProjectId(
        projectId,
        projectTitle: projectTitle,
        loadDetails: false,
      );
    }
    await start();
  }

  /// Picks the first loaded project when the saved id is empty or no longer
  /// in the list. Returns true when [setCurrentProjectId] ran, which already
  /// loads that project's timer state. [loadDetails] also loads the report.
  Future<bool> _ensureCurrentProject({bool loadDetails = true}) async {
    final projects = allProjectData.value?.data?.data;
    if (projects == null || projects.isEmpty) return false;

    final saved = _currentProjectId.value;
    final known = saved.isNotEmpty &&
        projects.any((project) => project.id == saved);
    if (known) return false;

    final first = projects.first;
    final id = first.id;
    if (id == null || id.isEmpty) return false;

    await setCurrentProjectId(
      id,
      projectTitle: first.title,
      loadDetails: loadDetails,
    );
    return _currentProjectId.value == id;
  }

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
  int _reportLoadGeneration = 0;

  /// Worked hours for the signed-in user, keyed by project id.
  final RxMap<String, double> projectTodayHours = <String, double>{}.obs;
  final RxMap<String, double> projectWeekHours = <String, double>{}.obs;

  /// Today and this UTC week from the summary total.
  ///
  /// The total is one number for the signed-in user. It is written onto a
  /// project only when every session in that response belongs to that project.
  Future<void> loadProjectTrackedHours() async {
    if (kDemoMode) {
      projectTodayHours.assignAll(_rangeHoursForSingleProject(DemoData.dailySummary));
      projectWeekHours.assignAll(_rangeHoursForSingleProject(DemoData.dailySummary));
      return;
    }
    try {
      final today = utcDateKey();
      final weekFrom = utcMondayKey(DateTime.now());
      final todaySummary = _reportRepository.fetchDailySummary(todayData: today);
      final weekSummary = _reportRepository.fetchDailySummary(
        from: weekFrom,
        to: today,
      );
      final todayResponse = await todaySummary;
      final weekResponse = await weekSummary;
      if (todayResponse.statusCode == 200) {
        projectTodayHours.assignAll(_rangeHoursForSingleProject(todayResponse));
      }
      if (weekResponse.statusCode == 200) {
        projectWeekHours.assignAll(_rangeHoursForSingleProject(weekResponse));
      }
    } catch (e) {
      appLog('Error loading project tracked hours: $e');
    }
  }

  Map<String, double> _rangeHoursForSingleProject(DailySummaryModel summary) {
    final sessions = summary.data?.sessions ?? const <Session>[];
    final ids = <String>{};
    for (final session in sessions) {
      final id = session.project?.id;
      if (id != null && id.isNotEmpty) ids.add(id);
    }
    if (ids.length != 1) return const {};
    final total = double.tryParse(summary.data?.totalTime ?? '');
    if (total == null) return const {};
    return {ids.single: total};
  }

  /// `day`, `week`, or `month`. Bounds are UTC date strings.
  final RxString reportPeriod = 'day'.obs;
  final RxString reportFrom = ''.obs;
  final RxString reportTo = ''.obs;

  void setReportPeriod(String period) {
    if (reportPeriod.value == period) return;
    reportPeriod.value = period;
    loadReportData(includeStrip: false);
  }

  Future<void> loadReportData({bool includeStrip = true}) async {
    // TEMPORARY demo mode — populate report screens without a backend.
    if (kDemoMode) {
      breakHoursData.value = DemoData.breakHours;
      dailySummaryData.value = DemoData.dailySummary;
      workingHoursSummary.value = DemoData.workingHours;
      final selected = utcDateKey(selectedDate.value);
      reportFrom.value = selected;
      reportTo.value = selected;
      reportLoadingState.value = LoadingState.idle;
      return;
    }
    final generation = ++_reportLoadGeneration;
    try {
      reportLoadingState.value = LoadingState.loading;
      dailySummaryData.value = null;

      final selected = utcDateKey(selectedDate.value);
      String? from;
      String? to;
      String? date;
      switch (reportPeriod.value) {
        case 'week':
          from = utcMondayKey(selectedDate.value);
          to = selected;
          break;
        case 'month':
          from = utcMonthStartKey(selectedDate.value);
          to = selected;
          break;
        default:
          date = selected;
      }
      reportFrom.value = from ?? selected;
      reportTo.value = to ?? selected;

      final summaryFuture = _reportRepository.fetchDailySummary(
        todayData: date,
        from: from,
        to: to,
      );
      final stripFuture = includeStrip
          ? _reportRepository.fetchWorkingHoursSummary(todayDate: selected)
          : null;

      final dailySummaryResponse = await summaryFuture;
      if (generation != _reportLoadGeneration) return;
      if (dailySummaryResponse.statusCode == 200) {
        dailySummaryData.value = dailySummaryResponse;
      }
      reportLoadingState.value = LoadingState.idle;

      if (stripFuture != null) {
        final workingHoursResponse = await stripFuture;
        if (generation != _reportLoadGeneration) return;
        if (workingHoursResponse.statusCode == 200) {
          workingHoursSummary.value = workingHoursResponse;
        }
      }

      appLog('Report data loaded successfully for date: $selected');
    } catch (e) {
      if (generation != _reportLoadGeneration) return;
      appLog('Error loading report data: $e');
      AppSnackBar.error('failedLoadReport'.tr);
    } finally {
      if (generation == _reportLoadGeneration) {
        reportLoadingState.value = LoadingState.idle;
      }
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
    selectedDate.value = DateTime.now();
    reportPeriod.value = 'day';
    await loadReportData();
  }
}
