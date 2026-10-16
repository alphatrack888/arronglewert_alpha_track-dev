import 'package:alpha_track/core/constant/app_storage_key.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/models/profile_model.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:get/get.dart';

/// Local + profile sync for automatic break reminders (hourly in-app prompt).
/// Server field `manualBreak` is the inverse: manualBreak true => automatic off.
class BreakPreferenceService extends GetxService {
  static const bool defaultAutomaticBreakEnabled = true;

  final StorageServices _storage = StorageServices.instance;
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _automaticBreakEnabled = defaultAutomaticBreakEnabled;
  final RxBool automaticBreakEnabledObs = defaultAutomaticBreakEnabled.obs;

  bool get automaticBreakEnabled => _automaticBreakEnabled;

  String get _storageKey => AppStorageKey.instance.automaticBreakEnabled;

  String get _userSetKey => AppStorageKey.instance.automaticBreakUserSet;

  /// Profile `manualBreak` is applied on fetch unless the user changed the toggle.
  static bool shouldApplyProfileManualBreak(bool userHasChangedPreference) =>
      !userHasChangedPreference;

  /// Maps profile.manualBreak to automatic-break-enabled (inverse).
  static bool automaticFromManualBreak(bool? manualBreak) {
    if (manualBreak == null) return defaultAutomaticBreakEnabled;
    return !manualBreak;
  }

  /// Maps UI automatic-break-enabled to API manualBreak.
  static bool manualBreakFromAutomatic(bool automaticEnabled) => !automaticEnabled;

  Future<void> loadFromLocal() async {
    final stored = _storage.getData(_storageKey);
    if (stored is bool) {
      _applyLocal(stored);
    } else {
      _applyLocal(defaultAutomaticBreakEnabled);
    }
  }

  /// Applies server `manualBreak` until the user changes Break Settings once.
  void syncFromProfile(ProfileModelData? data) {
    if (data == null) return;
    if (!shouldApplyProfileManualBreak(_userHasChangedPreference())) return;

    final automatic = automaticFromManualBreak(data.manualBreak);
    _applyLocal(automatic);
    _storage.saveData(_storageKey, automatic);
  }

  bool _userHasChangedPreference() => _storage.getData(_userSetKey) == true;

  Future<void> setAutomaticBreakEnabled(bool value) async {
    _applyLocal(value);
    await _storage.saveData(_storageKey, value);
    await _storage.saveData(_userSetKey, true);

    if (kDemoMode) return;
    if (_storage.getAccessToken().isEmpty) return;

    try {
      final ok = await _profileRepository.patchProfileFields({
        'manualBreak': manualBreakFromAutomatic(value),
      });
      if (!ok) {
        appLog('BreakPreferenceService: failed to sync manualBreak to profile');
      }
    } catch (e) {
      appLog('BreakPreferenceService: profile sync error: $e');
    }
  }

  void _applyLocal(bool value) {
    _automaticBreakEnabled = value;
    automaticBreakEnabledObs.value = value;
  }
}
