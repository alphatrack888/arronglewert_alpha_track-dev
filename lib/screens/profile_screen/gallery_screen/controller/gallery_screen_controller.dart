import 'dart:io';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';
import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryScreenController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Observable variables
  RxList<Datum> galleryImages = <Datum>[].obs;
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  Rx<GalleryModel?> galleryModel = Rx<GalleryModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchGalleryImages();
  }

  /// Fetch gallery images from API
  Future<void> fetchGalleryImages() async {
    try {
      isLoading.value = true;
      final response = await _profileRepository.fetchGallery();

      if (response.success == true && response.data != null) {
        galleryModel.value = response;
        galleryImages.value = response.data!;
        appLog("Gallery images fetched successfully");
      } else {
        errorLog(
          "Failed to fetch gallery images",
          response.message ?? "Unknown error",
        );
        AppSnackBar.error( "Failed to fetch gallery images");
      }
    } catch (e) {
      errorLog("Exception in fetchGalleryImages", e);
      AppSnackBar.error( "Failed to fetch gallery images");
    } finally {
      isLoading.value = false;
    }
  }

  /// Show image picker using existing service
  Future<void> showImagePicker() async {
    try {
      // Use your existing ImagePickerService
      final File? pickedImage = await _imagePickerService.pickImage(
        Get.context!,
      );

      if (pickedImage != null) {
        await uploadImage(pickedImage);
      }
    } catch (e) {
      errorLog("Exception in showImagePicker", e);
      AppSnackBar.error( "Failed to pick image");
    }
  }

  /// Pick image from camera directly
  Future<void> pickFromCamera() async {
    try {
      final File? image = await _imagePickerService.pickFromCamera(
        Get.context!,
      );
      if (image != null) {
        await uploadImage(image);
      }
    } catch (e) {
      errorLog("Exception in pickFromCamera", e);
      AppSnackBar.error( "Failed to take photo");
    }
  }

  /// Pick image from gallery directly
  Future<void> pickFromGallery() async {
    try {
      final File? image = await _imagePickerService.pickFromGallery(
        Get.context!,
      );
      if (image != null) {
        await uploadImage(image);
      }
    } catch (e) {
      errorLog("Exception in pickFromGallery", e);
      AppSnackBar.error( "Failed to pick image");
    }
  }

  /// Upload image to gallery
  Future<void> uploadImage(File imageFile) async {
    try {
      isUploading.value = true;
      AppSnackBar.message( "Please wait while we upload your image...");

      final success = await _profileRepository.uploadGalleryImage(
        image: imageFile,
      );

      if (success) {
        AppSnackBar.success("Image uploaded successfully!");
        // Refresh gallery after successful upload
        await fetchGalleryImages();
      } else {
        AppSnackBar.error( "Failed to upload image");
      }
    } catch (e) {
      errorLog("Exception in uploadImage", e);
      AppSnackBar.error( "Failed to upload image");
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete image from gallery (if API supports it)
  Future<void> deleteImage(String imageId) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Delete Image"),
          content: const Text("Are you sure you want to delete this image?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Remove from local list immediately for better UX
        galleryImages.removeWhere((image) => image.id == imageId);

        // Here you would call API to delete from server
        // await _profileRepository.deleteGalleryImage(imageId);

        AppSnackBar.success("Image deleted successfully!");
      }
    } catch (e) {
      errorLog("Exception in deleteImage", e);
      AppSnackBar.error( "Failed to delete image");
    }
  }

  /// Refresh gallery
  Future<void> refreshGallery() async {
    await fetchGalleryImages();
  }


  /// Get total images count
  int get totalImages => galleryImages.length;

  /// Check if gallery is empty
  bool get isGalleryEmpty => galleryImages.isEmpty && !isLoading.value;
}
