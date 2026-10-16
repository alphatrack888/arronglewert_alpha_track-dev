import 'package:alpha_track/services/break_preference/break_preference_service.dart';
import 'package:get/get.dart';

class BreakSettingsController extends GetxController {
  final BreakPreferenceService _breakPrefs = Get.find<BreakPreferenceService>();

  RxBool get automaticBreakEnabled => _breakPrefs.automaticBreakEnabledObs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    await _breakPrefs.loadFromLocal();
  }

  Future<void> setAutomaticBreak(bool value) async {
    await _breakPrefs.setAutomaticBreakEnabled(value);
  }
}
