import 'dart:io';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';
import 'package:alpha_track/services/image_picker_service/image_picker_service.dart';
import 'package:alpha_track/services/repository/profile_repository/profile_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
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
    // TEMPORARY demo mode — show sample gallery images without a backend.
    if (kDemoMode) {
      galleryModel.value = DemoData.gallery;
      galleryImages.value = DemoData.gallery.data ?? [];
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      final response = await _profileRepository.fetchGallery();

      if (response.success == true && response.data != null) {
        galleryModel.value = response;
        galleryImages.value = response.data!;
        appLog("Gallery images fetched successfully");
      } else {
        errorLog(
          'failedFetchGallery'.tr,
          response.message ?? "Unknown error",
        );
        AppSnackBar.error( 'failedFetchGallery'.tr);
      }
    } catch (e) {
      errorLog("Exception in fetchGalleryImages", e);
      AppSnackBar.error( 'failedFetchGallery'.tr);
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
      AppSnackBar.error( 'failedPickImage'.tr);
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
      AppSnackBar.error( 'failedTakePhoto'.tr);
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
      AppSnackBar.error( 'failedPickImage'.tr);
    }
  }

  /// Upload image to gallery
  Future<void> uploadImage(File imageFile) async {
    // Demo/review builds: no backend — add a new gallery tile so the upload
    // visibly succeeds instead of erroring. AppImage renders network URLs (not
    // local file paths), so use a picsum tile seeded by the picked file, in
    // keeping with the demo gallery.
    if (kDemoMode) {
      final seed = imageFile.path.hashCode.abs() % 1000;
      galleryImages.insert(
        0,
        Datum(id: 'demo-$seed', image: 'https://picsum.photos/seed/$seed/600/600'),
      );
      AppSnackBar.success('imageAdded'.tr);
      return;
    }
    try {
      isUploading.value = true;
      AppSnackBar.message( 'uploadingImage'.tr);

      final success = await _profileRepository.uploadGalleryImage(
        image: imageFile,
      );

      if (success) {
        AppSnackBar.success('imageUploaded'.tr);
        // Refresh gallery after successful upload
        await fetchGalleryImages();
      } else {
        AppSnackBar.error( 'failedUploadImage'.tr);
      }
    } catch (e) {
      errorLog("Exception in uploadImage", e);
      AppSnackBar.error( 'failedUploadImage'.tr);
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete image from gallery (if API supports it).
  ///
  /// Confirmation is handled by the UI layer (the gallery options sheet uses
  /// [DsDialog.confirm] before calling this), so this just performs the delete.
  Future<void> deleteImage(String imageId) async {
    try {
      // Remove from local list immediately for better UX
      galleryImages.removeWhere((image) => image.id == imageId);

      // Here you would call API to delete from server
      // await _profileRepository.deleteGalleryImage(imageId);

      AppSnackBar.success('imageDeleted'.tr);
    } catch (e) {
      errorLog("Exception in deleteImage", e);
      AppSnackBar.error('failedDeleteImage'.tr);
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
