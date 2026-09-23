import 'package:alpha_track/screens/profile_screen/profile_screen_main/models/profile_model.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:get/get.dart';

import '../../../../utils/app_log/app_log.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final StorageServices storageServie = StorageServices.instance;
  RxBool isLoading = false.obs;
  var profileData = Rxn<ProfileModel>();

  // Add this flag to force image refresh
  var forceImageRefresh = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  void onTap() {
    print("===================${profileData.value!.data!.profile}");
  }

  Future<void> fetchProfile({bool refreshImage = false}) async {
    try {
      isLoading(true);

      // Set the force refresh flag
      if (refreshImage) {
        forceImageRefresh.value = true;
      }
      var response = await _profileRepository.getProfile();
      // ignore: unnecessary_null_comparison
      if (response != null) {
        profileData.value = response;
        // Set user id in storage
        await storageServie.setUserId(response.data?.id ?? '');
        appLog("User id: ${storageServie.getUserId()}");
        // Reset the flag after a short delay to allow the UI to update
        if (refreshImage) {
          await Future.delayed(const Duration(milliseconds: 100));
          forceImageRefresh.value = false;
        }
      }
    } catch (e) {
      appLog(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Method to refresh profile image specifically
  Future<void> refreshProfileImage() async {
    forceImageRefresh.value = true;
    await fetchProfile(refreshImage: true);
  }

  //! Getter for Profile

  String get fullName => profileData.value?.data?.name ?? '';
  String get email => profileData.value?.data?.email ?? '';
  String get phone => profileData.value?.data?.phone ?? '';
  String get address => profileData.value?.data?.address ?? '';
  String get designation => profileData.value?.data?.role ?? '';
  String get subscriptionStatus =>
      profileData.value?.data?.subscriptionStatus ?? '';
  String get subscriptionTier =>
      profileData.value?.data?.subscriptionTier ?? '';
}
