import 'package:alpha_track/services/break_preference/break_preference_service.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:get/get.dart';

class BreakSettingsController extends GetxController {
  final BreakPreferenceService _breakPrefs = Get.find<BreakPreferenceService>();
  final ProfileRepository _profileRepository = ProfileRepository();

  RxBool get automaticBreakEnabled => _breakPrefs.automaticBreakEnabledObs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    await _breakPrefs.loadFromLocal();
    if (kDemoMode) return;
    if (StorageServices.instance.getAccessToken().isEmpty) return;
    final profile = await _profileRepository.getProfile();
    _breakPrefs.syncFromProfile(profile.data);
  }

  Future<void> setAutomaticBreak(bool value) async {
    await _breakPrefs.setAutomaticBreakEnabled(value);
  }
}
