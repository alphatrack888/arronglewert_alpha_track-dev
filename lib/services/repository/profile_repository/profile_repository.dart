import 'dart:io';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/gallery_api_contract.dart';
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_upload_result.dart';
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

  //! Upload Gallery Image (POST /gallery/ — multipart field `images`, Cloudinary on server)
  Future<GalleryUploadResult> uploadGalleryImage({required File image}) async {
    try {
      final fileName = image.path.split('/').last;
      final mime = _getMimeType(fileName);
      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('Gallery upload error: image file is empty');
        return const GalleryUploadResult(
          success: false,
          message: 'galleryImageUnreadable',
        );
      }

      final formData = FormData();
      formData.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType.parse(mime),
          ),
        ),
      );

      final response = await apiServices.api.sendRequest.post(
        ApiUrls.gallery,
        data: formData,
      );
      final data = response.data;
      final status = response.statusCode;
      if (kDebugMode) {
        appLog('Gallery upload response: status=$status');
      }
      final parsed = parseGalleryUploadResponse(data, status);
      return GalleryUploadResult(
        success: parsed.success,
        message: parsed.message,
        createdItems: parsed.createdItems,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (kDebugMode) {
        appLog('Gallery upload DioException: status=$status');
      }
      final parsed = parseGalleryUploadResponse(e.response?.data, status);
      debugPrint('Gallery upload error: $e message=${parsed.message}');
      return GalleryUploadResult(
        success: false,
        message: parsed.message,
      );
    } catch (e) {
      debugPrint('Gallery upload error: $e');
      return const GalleryUploadResult(success: false);
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
  Future<GalleryFetchOutcome> fetchGallery() async {
    try {
      final response = await apiServices.api.sendRequest.get(ApiUrls.gallery);
      final status = response.statusCode;
      if (status != null && status >= 200 && status < 300) {
        return parseGalleryListResponse(response.data);
      }
      debugPrint('Gallery fetch failed: status=$status');
      return const GalleryFetchOutcome(ok: false);
    } on DioException catch (e) {
      debugPrint('Gallery fetch DioException: ${e.response?.statusCode}');
      return GalleryFetchOutcome(
        ok: false,
        serverMessage: e.response?.data is Map
            ? (e.response?.data as Map)['message']?.toString()
            : null,
      );
    } catch (e) {
      debugPrint('Gallery fetch error: $e');
      return const GalleryFetchOutcome(ok: false);
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
