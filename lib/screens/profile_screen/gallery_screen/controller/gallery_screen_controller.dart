import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/gallery_api_contract.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_upload_result.dart';
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
  final RxInt galleryTotalCount = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  final RxBool lastGalleryFetchOk = true.obs;

  /// Inline banner after upload (snackbars can be missed under the overlay).
  final RxnString uploadBannerMessage = RxnString();
  final RxBool uploadBannerIsError = false.obs;

  @override
  void onInit() {
    super.onInit();
    recoverLostPickerImage();
    fetchGalleryImages();
  }

  /// Android may kill the app while the system picker is open; recover the pick.
  Future<void> recoverLostPickerImage() async {
    try {
      final response = await ImagePicker().retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      if (response.exception != null) {
        errorLog('retrieveLostData', response.exception!);
        _showUploadFailure('failedPickImage'.tr);
        return;
      }
      final lost = response.file;
      if (lost == null) {
        return;
      }
      final file = await materializePickedImageFile(lost);
      if (file != null) {
        await uploadImage(file);
      } else {
        _showUploadFailure('galleryImageUnreadable'.tr);
      }
    } catch (e) {
      errorLog('recoverLostPickerImage', e);
    }
  }

  /// Fetch gallery images from API
  Future<bool> fetchGalleryImages({
    bool showLoading = true,
    bool quiet = false,
  }) async {
    if (kDemoMode) {
      galleryImages.value = DemoData.gallery.data ?? [];
      galleryTotalCount.value = galleryImages.length;
      lastGalleryFetchOk.value = true;
      isLoading.value = false;
      return true;
    }
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      final outcome = await _profileRepository.fetchGallery();

      if (outcome.ok) {
        _applyGalleryFetchOutcome(outcome);
        lastGalleryFetchOk.value = true;
        appLog(
          'Gallery images fetched: ${outcome.items.length}, total=${outcome.totalCount}',
        );
        return true;
      }

      lastGalleryFetchOk.value = false;
      errorLog(
        'failedFetchGallery'.tr,
        outcome.serverMessage ?? 'Unknown error',
      );
      final message = outcome.serverMessage?.isNotEmpty == true
          ? outcome.serverMessage!
          : outcome.errorKey.tr;
      if (!quiet) {
        AppSnackBar.error(message);
        _setUploadBanner(message, isError: true);
      }
      return false;
    } catch (e) {
      lastGalleryFetchOk.value = false;
      errorLog('Exception in fetchGalleryImages', e);
      if (!quiet) {
        AppSnackBar.error('failedFetchGallery'.tr);
        _setUploadBanner('failedFetchGallery'.tr, isError: true);
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool get _canStartUpload => !isUploading.value;

  Future<void> _pickAndUpload(Future<File?> Function() pick) async {
    if (!_canStartUpload) return;
    try {
      final file = await pick();
      if (file != null) {
        await uploadImage(file);
      }
    } catch (e) {
      errorLog('pickAndUpload', e);
    }
  }

  Future<void> showImagePicker() async {
    await _pickAndUpload(
      () => _imagePickerService.pickImage(Get.context!),
    );
  }

  Future<void> pickFromCamera() async {
    await _pickAndUpload(
      () => _imagePickerService.pickFromCamera(Get.context!),
    );
  }

  Future<void> pickFromGallery() async {
    await _pickAndUpload(
      () => _imagePickerService.pickFromGallery(Get.context!),
    );
  }

  Future<void> uploadImage(File imageFile) async {
    if (kDemoMode) {
      final seed = imageFile.path.hashCode.abs() % 1000;
      galleryImages.insert(
        0,
        Datum(
          id: 'demo-$seed',
          image: 'https://picsum.photos/seed/$seed/600/600',
        ),
      );
      galleryTotalCount.value += 1;
      AppSnackBar.success('imageAdded'.tr);
      return;
    }

    GalleryUploadResult result;
    try {
      isUploading.value = true;
      uploadBannerMessage.value = null;
      result = await _profileRepository.uploadGalleryImage(image: imageFile);
    } catch (e) {
      errorLog('Exception in uploadImage', e);
      result = const GalleryUploadResult(success: false);
    } finally {
      isUploading.value = false;
    }

    final message = _uploadResultMessage(result);
    if (result.success) {
      final beforeCount = galleryImages.length;
      galleryImages.value = mergeGalleryItems(
        existing: galleryImages,
        created: result.createdItems,
      );
      final added = galleryImages.length - beforeCount;
      if (added > 0) {
        galleryTotalCount.value += added;
      }
      _setUploadBanner(message, isError: false);
      _notifyUploadAfterOverlay(message, isError: false);
      final refreshed = await _refreshGalleryAfterUpload();
      if (!refreshed) {
        _showUploadFailure('galleryUploadRefreshFailed'.tr);
      }
    } else {
      _showUploadFailure(message);
    }
  }

  String _uploadResultMessage(GalleryUploadResult result) {
    const translationKeys = {
      'galleryImageUnreadable',
      'galleryUploadEmployeeOnly',
      'galleryUploadAuthRequired',
    };
    if (translationKeys.contains(result.message)) {
      return result.message!.tr;
    }
    if (result.message?.isNotEmpty == true) {
      return result.message!;
    }
    return result.success ? 'imageUploaded'.tr : 'failedUploadImage'.tr;
  }

  void _showUploadFailure(String message) {
    _setUploadBanner(message, isError: true);
    _notifyUploadAfterOverlay(message, isError: true);
  }

  void _setUploadBanner(String message, {required bool isError}) {
    uploadBannerMessage.value = message;
    uploadBannerIsError.value = isError;
    Future.delayed(const Duration(seconds: 6), () {
      if (uploadBannerMessage.value == message) {
        uploadBannerMessage.value = null;
      }
    });
  }

  void _notifyUploadAfterOverlay(String message, {required bool isError}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isError) {
        AppSnackBar.error(message, duration: const Duration(seconds: 4));
      } else {
        AppSnackBar.success(message, duration: const Duration(seconds: 4));
      }
    });
  }

  Future<bool> _refreshGalleryAfterUpload() async {
    if (kDemoMode) return true;
    try {
      final outcome = await _profileRepository.fetchGallery();
      if (outcome.ok) {
        _applyGalleryFetchOutcome(outcome);
        lastGalleryFetchOk.value = true;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteImage(String imageId) async {
    if (kDemoMode || imageId.startsWith('demo')) {
      galleryImages.removeWhere((image) => image.id == imageId);
      if (galleryTotalCount.value > 0) {
        galleryTotalCount.value -= 1;
      }
      AppSnackBar.success('imageDeleted'.tr);
      return;
    }

    try {
      final success =
          await _profileRepository.deleteGalleryImages([imageId]);

      if (success) {
        galleryImages.removeWhere((image) => image.id == imageId);
        if (galleryTotalCount.value > 0) {
          galleryTotalCount.value -= 1;
        }
        AppSnackBar.success('imageDeleted'.tr);
      } else {
        AppSnackBar.error('failedDeleteImage'.tr);
        await fetchGalleryImages();
      }
    } catch (e) {
      errorLog('Exception in deleteImage', e);
      AppSnackBar.error('failedDeleteImage'.tr);
      await fetchGalleryImages();
    }
  }

  Future<void> refreshGallery() async {
    await fetchGalleryImages();
  }

  void _applyGalleryFetchOutcome(GalleryFetchOutcome outcome) {
    galleryImages.value = outcome.items;
    galleryTotalCount.value = outcome.totalCount ?? outcome.items.length;
  }

  int get totalImages => galleryTotalCount.value;

  bool get isGalleryEmpty =>
      galleryImages.isEmpty && !isLoading.value && lastGalleryFetchOk.value;
}
