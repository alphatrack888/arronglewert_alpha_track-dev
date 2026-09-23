import 'dart:io';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/models/profile_model.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';

class PersonalInformationController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();

  // Text controllers for form fields
  final TextEditingController fullNameController = TextEditingController();
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
      if (profileData.value?.data?.phone != null) {
        contactNumberController.text = profileData.value!.data!.phone!;
      }
      appLog('✅ Profile data loaded successfully');
    } catch (e) {
      appLog('❌ Error loading profile: $e');
      AppSnackBar.error('Failed to load profile data');
    } finally {
      isLoading.value = false;
    }
  }

  /// Set profile image
  void setProfileImage(File? image) {
    profileImage.value = image;
    appLog('📸 Profile image set: ${image?.path}');
  }

  /// Update profile information
  Future<void> updateProfile() async {
    try {
      // Validate input
      if (fullNameController.text.trim().isEmpty) {
        AppSnackBar.error('Please enter your full name');
        return;
      }

      if (contactNumberController.text.trim().isEmpty) {
        AppSnackBar.error('Please enter your contact number');
        return;
      }

      isLoading.value = true;
      appLog('🔄 Updating profile...');

      final success = await _profileRepository.updaeProfile(
        fullName: fullNameController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
        profileImage: profileImage.value,
      );

      if (success) {
        appLog('✅ Profile updated successfully');

        // Clear the selected image since it's now uploaded
        profileImage.value = null;

        // Refresh profile with image refresh flag
        await Get.find<ProfileController>().refreshProfileImage();

        AppSnackBar.success('Profile updated successfully!');

        // Optional: Go back to the previous screen
        Get.back();
      } else {
        appLog('❌ Failed to update profile');
        AppSnackBar.error('Failed to update profile. Please try again.');
      }
    } catch (e) {
      appLog('❌ Error updating profile: $e');
      AppSnackBar.error('An error occurred while updating profile');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all form data
  void clearForm() {
    fullNameController.clear();
    contactNumberController.clear();
    profileImage.value = null;
    appLog('🗑️ Form data cleared');
  }

  /// Check if form has changes
  bool get hasChanges {
    return fullNameController.text.trim().isNotEmpty ||
        contactNumberController.text.trim().isNotEmpty ||
        profileImage.value != null;
  }
}
