import 'dart:io';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/models/profile_model.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';

class PersonalInformationController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();

  // Text controllers for form fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  Rxn<ProfileModel> profileData = Rxn<ProfileModel>();

  // Observable variables
  var isLoading = false.obs;
  var profileImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    profileData = Get.find<ProfileController>().profileData;
    loadProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    super.onClose();
  }

  /// Load existing profile data
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      appLog('🔥 Loading profile data...');

      if (profileData.value?.data?.name != null) {
        fullNameController.text = profileData.value!.data!.name!;
      }
      if (profileData.value?.data?.email != null) {
        emailController.text = profileData.value!.data!.email!;
      }
      if (profileData.value?.data?.phone != null) {
        contactNumberController.text = profileData.value!.data!.phone!;
      }
      appLog('✅ Profile data loaded successfully');
    } catch (e) {
      appLog('❌ Error loading profile: $e');
      AppSnackBar.error('failedLoadProfile'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Set profile image
  void setProfileImage(File? image) {
    profileImage.value = image;
    appLog('📸 Profile image set: ${image?.path}');
  }

  /// Update profile information. Returns true on success so the screen can pop
  /// (via dsPop) — this method no longer navigates itself.
  Future<bool> updateProfile() async {
    // Validate input
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = contactNumberController.text.trim();

    if (name.isEmpty) {
      AppSnackBar.error('vFullName'.tr);
      return false;
    }
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      AppSnackBar.error('vValidEmail'.tr);
      return false;
    }
    if (phone.isEmpty) {
      AppSnackBar.error('vPhone'.tr);
      return false;
    }

    // Demo/review builds: no backend session, so apply the edit locally to the
    // shared ProfileController + demo store and confirm success. This is what
    // makes the "Save Changes" button visibly work in TestFlight demo builds.
    if (kDemoMode) {
      final profileCtrl = Get.find<ProfileController>();
      final data = profileCtrl.profileData.value?.data ?? DemoData.profile.data;
      data?.name = name;
      data?.email = email;
      data?.phone = phone;
      profileCtrl.profileData.value = DemoData.profile;
      profileCtrl.profileData.refresh();
      profileImage.value = null;
      AppSnackBar.success('profileUpdated'.tr);
      return true;
    }

    try {
      isLoading.value = true;
      appLog('🔄 Updating profile...');

      final success = await _profileRepository.updaeProfile(
        fullName: name,
        email: email,
        contactNumber: phone,
        profileImage: profileImage.value,
      );

      if (success) {
        appLog('✅ Profile updated successfully');
        profileImage.value = null;
        await Get.find<ProfileController>().refreshProfileImage();
        AppSnackBar.success('profileUpdated'.tr);
        return true;
      } else {
        appLog('❌ Failed to update profile');
        AppSnackBar.error('profileUpdateFailed'.tr);
        return false;
      }
    } catch (e) {
      appLog('❌ Error updating profile: $e');
      AppSnackBar.error('profileUpdateError'.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all form data
  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    contactNumberController.clear();
    profileImage.value = null;
    appLog('🗑️ Form data cleared');
  }

  /// Check if form has changes
  bool get hasChanges {
    return fullNameController.text.trim().isNotEmpty ||
        emailController.text.trim().isNotEmpty ||
        contactNumberController.text.trim().isNotEmpty ||
        profileImage.value != null;
  }
}
