import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart';
import 'package:alpha_track/screens/profile_screen/pay_role_screen/models/payrole_model.dart';
import 'package:dio/dio.dart';
import '../../../screens/profile_screen/profile_screen_main/models/profile_model.dart';
import '../../api/api_services.dart';

class ProfileRepository {
  ApiServices apiServices = ApiServices.instance;

  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiServices.apiGetServices(ApiUrls.profile);
      if (response != null) {
        return ProfileModel.fromJson(response);
      }
      return ProfileModel();
    } catch (e) {
      return ProfileModel();
    }
  }

  /// JSON PATCH for profile fields (e.g. manualBreak) without multipart.
  Future<bool> patchProfileFields(Map<String, dynamic> fields) async {
    try {
      final response = await apiServices.apiPatchServices(
        url: ApiUrls.updateProfile,
        body: fields,
      );
      return response != null &&
          (response['success'] == true || response['success'] == null);
    } catch (e) {
      debugPrint('patchProfileFields error: $e');
      return false;
    }
  }

  Future<bool> updaeProfile({
    String? fullName,
    String? contactNumber,
    String? email,
    File? profileImage,
  }) async {
    try {
      //! Create FormData for multipart request
      FormData formData = FormData();

      //! Add text fields if they are provided
      if (fullName != null && fullName.isNotEmpty) {
        formData.fields.add(MapEntry('name', fullName));
      }
      if (email != null && email.isNotEmpty) {
        formData.fields.add(MapEntry('email', email));
      }
      if (contactNumber != null && contactNumber.isNotEmpty) {
        formData.fields.add(MapEntry('phone', contactNumber));
      }

      //! Add file if provided
      if (profileImage != null) {
        // Check if file exists before uploading
        if (await profileImage.exists()) {
          String fileName = profileImage.path.split('/').last;
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                profileImage.path,
                filename: fileName,
                contentType: DioMediaType.parse(_getMimeType(fileName)),
              ),
            ),
          );
        } else {
          throw Exception('Profile image file does not exist');
        }
      }

      //! DON'T manually set Content-Type - let Dio handle it for FormData
      Options options = Options(
        // Remove the manual Content-Type header
        // Dio will automatically set 'multipart/form-data' for FormData
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      );

      final response = await apiServices.apiPatchServices(
        url: ApiUrls.updateProfile,
        body: formData,
        options: options,
      );

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Profile update error: $e'); // Add logging
      return false;
    }
  }

  // Helper method to get proper MIME type
  String _getMimeType(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  //! Upload Gallery Image
  Future<bool> uploadGalleryImage({required File image}) async {
    try {
      if (!await image.exists()) {
        debugPrint('Gallery upload error: image file does not exist');
        return false;
      }

      final fileName = image.path.split('/').last;
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename: fileName,
            contentType: DioMediaType.parse(_getMimeType(fileName)),
          ),
        ),
      );

      final response = await apiServices.apiPostServices(
        url: ApiUrls.gallery,
        body: formData,
      );
      return response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('Gallery upload error: $e');
      return false;
    }
  }

  //! Delete gallery images by server _id
  Future<bool> deleteGalleryImages(List<String> imageIds) async {
    if (imageIds.isEmpty) return false;
    try {
      final response = await apiServices.apiDeleteServices(
        url: ApiUrls.gallery,
        body: {'images': imageIds},
      );
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Gallery delete error: $e');
      return false;
    }
  }

  //! Get Gallery Image
  Future<GalleryModel> fetchGallery() async {
    try {
      final response = await apiServices.apiGetServices(ApiUrls.gallery);
      if (response != null) {
        return GalleryModel.fromJson(response);
      }
      return GalleryModel();
    } catch (e) {
      return GalleryModel();
    }
  }

  //! Payrole Document Get
  Future<PayrollModel> fetchPayroll() async {
    try {
      final response = await apiServices.apiGetServices(ApiUrls.payroll);
      if (response != null) {
        return PayrollModel.fromJson(response);
      }
      return PayrollModel();
    } catch (e) {
      return PayrollModel();
    }
  }
}
