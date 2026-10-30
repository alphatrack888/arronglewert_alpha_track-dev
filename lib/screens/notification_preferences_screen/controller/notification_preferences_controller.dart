import 'dart:async';

import 'package:alpha_track/screens/notification_preferences_screen/models/notification_preferences_model.dart';
import 'package:alpha_track/services/push_notification_service/notification_hygiene.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/repository/notification_repository/notification_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPreferencesController extends GetxController
    with WidgetsBindingObserver {
  final NotificationRepository _repository = NotificationRepository();

  var isLoading = true.obs;
  var isSaving = false.obs;
  var preferences = NotificationPreferences().obs;
  var demoMode = false.obs;
  final osPrompt = Rxn<OsNotificationPrompt>();

  Timer? _saveDebounce;
  static const _debounceMs = 500;
  bool _resolvingPermission = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    demoMode.value = kDemoMode;
    fetchPreferences();
    refreshOsPermission();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveDebounce?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshOsPermission();
    }
  }

  Future<void> refreshOsPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final permanent = await Permission.notification.isPermanentlyDenied;
      osPrompt.value = osNotificationPrompt(
        allowed: _osAllowed(settings.authorizationStatus),
        permanentlyDenied: permanent,
      );
    } catch (e) {
      appLog("Error reading notification permission: $e");
    }
  }

  bool _osAllowed(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  /// Asks once when the system dialog can still appear. Opens the app's
  /// system page only when it cannot. Does not change [pushEnabled].
  Future<void> onOsPermissionButton() async {
    if (_resolvingPermission) return;
    final prompt = osPrompt.value;
    if (prompt == null || !prompt.showStatus) return;
    _resolvingPermission = true;
    try {
      if (prompt.action == OsNotificationAction.openSettings) {
        await openAppSettings();
        return;
      }
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (_osAllowed(settings.authorizationStatus)) {
        if (!kDemoMode) {
          await PushNotificationService.instance.registerCurrentToken();
        }
        await refreshOsPermission();
        return;
      }
      if (await Permission.notification.isPermanentlyDenied) {
        await openAppSettings();
      }
      await refreshOsPermission();
    } catch (e) {
      appLog("Error resolving notification permission: $e");
    } finally {
      _resolvingPermission = false;
    }
  }

  Future<void> fetchPreferences({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      if (kDemoMode) {
        preferences.value = NotificationPreferences();
        return;
      }
      final result = await _repository.getPreferences();
      if (result != null) {
        preferences.value = result;
      }
    } catch (e) {
      appLog("Error fetching notification preferences: $e");
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  void _scheduleAutoSave() {
    if (isLoading.value || kDemoMode) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => savePreferences(showSuccessSnackbar: false),
    );
  }

  void setPushEnabled(bool value) {
    preferences.update((p) => p?.pushEnabled = value);
    _scheduleAutoSave();
    if (value) {
      unawaited(_afterPushEnabled());
    }
  }

  Future<void> _afterPushEnabled() async {
    await refreshOsPermission();
    final prompt = osPrompt.value;
    if (prompt == null) return;
    if (!prompt.showStatus) {
      if (!kDemoMode) {
        await PushNotificationService.instance.registerCurrentToken();
      }
      return;
    }
    await onOsPermissionButton();
  }

  void setCategory(String category, bool value) {
    preferences.update((p) {
      switch (category) {
        case 'leave':
          p?.categories.leave = value;
          break;
        case 'project':
          p?.categories.project = value;
          break;
        case 'payroll':
          p?.categories.payroll = value;
          break;
        case 'overtime':
          p?.categories.overtime = value;
          break;
        case 'attendance':
          p?.categories.attendance = value;
          break;
        case 'subscription':
          p?.categories.subscription = value;
          break;
      }
    });
    _scheduleAutoSave();
  }

  void setDigestMode(String value) {
    preferences.update((p) => p?.digestMode = value);
    _scheduleAutoSave();
  }

  void setLanguage(String value) {
    preferences.update((p) => p?.language = value);
    _scheduleAutoSave();
  }

  Future<bool> savePreferences({bool showSuccessSnackbar = true}) async {
    if (kDemoMode) {
      if (showSuccessSnackbar) {
        AppSnackBar.message(AppString.preferencesNotAvailableInDemo.tr);
      }
      return false;
    }
    isSaving.value = true;
    try {
      final success = await _repository.updatePreferences(preferences.value);
      if (success) {
        await fetchPreferences(silent: !showSuccessSnackbar);
        if (showSuccessSnackbar) {
          AppSnackBar.success(AppString.preferencesSaved.tr);
        }
      } else {
        if (showSuccessSnackbar) {
          AppSnackBar.error(AppString.preferencesSaveFailed.tr);
        }
      }
      return success;
    } catch (e) {
      appLog("Error saving notification preferences: $e");
      if (showSuccessSnackbar) {
        AppSnackBar.error(AppString.preferencesSaveFailed.tr);
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
