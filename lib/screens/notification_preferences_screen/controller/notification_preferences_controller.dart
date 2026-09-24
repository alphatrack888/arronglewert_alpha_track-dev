import 'package:alpha_track/screens/notification_preferences_screen/models/notification_preferences_model.dart';
import 'package:alpha_track/services/repository/notification_repository/notification_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';

class NotificationPreferencesController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  var isLoading = true.obs;
  var isSaving = false.obs;
  var preferences = NotificationPreferences().obs;

  @override
  void onInit() {
    super.onInit();
    fetchPreferences();
  }

  Future<void> fetchPreferences() async {
    isLoading.value = true;
    try {
      final result = await _repository.getPreferences();
      if (result != null) {
        preferences.value = result;
      }
    } catch (e) {
      appLog("Error fetching notification preferences: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setPushEnabled(bool value) {
    preferences.update((p) => p?.pushEnabled = value);
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
  }

  void setDigestMode(String value) {
    preferences.update((p) => p?.digestMode = value);
  }

  void setLanguage(String value) {
    preferences.update((p) => p?.language = value);
  }

  Future<bool> savePreferences() async {
    isSaving.value = true;
    try {
      final success = await _repository.updatePreferences(preferences.value);
      if (success) {
        AppSnackBar.success(AppString.preferencesSaved.tr);
      } else {
        AppSnackBar.error(AppString.preferencesSaveFailed.tr);
      }
      return success;
    } catch (e) {
      appLog("Error saving notification preferences: $e");
      AppSnackBar.error(AppString.preferencesSaveFailed.tr);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
