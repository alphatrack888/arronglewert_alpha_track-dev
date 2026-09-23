import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/notes_screen/models/get_all_notes_models.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';

class NoteRepository {
  ApiServices apiServices = ApiServices.instance;
  StorageServices storageServices = StorageServices.instance;

  //! Get All Notes
  Future<AllNoteModel> getAllNotes({required String projectId}) async {
    try {
      final url = ApiUrls.allNotes + projectId;
      appLog('🌐 API URL: $url');
      final responseData = await apiServices.apiGetServices(url);
      appLog('📦 API Response Data Type: ${responseData.runtimeType}');
      appLog(
        '📦 API Response Keys: ${responseData is Map ? (responseData as Map<String, dynamic>).keys.toList() : 'Not a Map'}',
      );
      if (responseData != null) {
        try {
          appLog('🔧 Raw responseData: ${responseData}');
          // Handle different response structures
          AllNoteModel model;
          if (responseData is Map<String, dynamic>) {
            final responseMap = responseData;
            appLog('🔍 Response structure keys: ${responseMap.keys.toList()}');
            // Check if response already has the expected structure
            if (responseMap.containsKey('statusCode') &&
                responseMap.containsKey('success')) {
              // Response has wrapper structure
              model = AllNoteModel.fromJson(responseMap);
            } else if (responseMap.containsKey('data') || responseMap.isEmpty) {
              // Response might be direct data or wrapped differently
              model = AllNoteModel(
                statusCode: 200,
                success: true,
                message: 'Notes retrieved successfully',
                data: responseMap.containsKey('data')
                    ? (responseMap['data'] as List?)
                              ?.map((x) => Datum.fromJson(x))
                              .toList() ??
                          []
                    : [],
              );
            } else {
              // Assume responseData is direct array or single object
              model = AllNoteModel(
                statusCode: 200,
                success: true,
                message: 'Notes retrieved successfully',
                data: [],
              );
            }
          } else if (responseData is List) {
            // Direct array response
            appLog(
              '📋 Direct array response with ${(responseData).length} items',
            );
            model = AllNoteModel(
              statusCode: 200,
              success: true,
              message: 'Notes retrieved successfully',
              data: (responseData).map((x) => Datum.fromJson(x)).toList(),
            );
          } else {
            // Unexpected format
            appLog('⚠️ Unexpected response format: ${responseData}');
            model = AllNoteModel(
              statusCode: 500,
              success: false,
              message: 'Unexpected response format',
              data: [],
            );
          }
          appLog('✅ Model created successfully');
          appLog(
            '📊 Model details: statusCode=${model.statusCode}, success=${model.success}, message=${model.message}',
          );
          appLog('📦 Data array length: ${model.data?.length ?? 0}');
          if (model.data != null && model.data!.isNotEmpty) {
            appLog(
              '🎯 First note sample: id=${model.data!.first.id}, content=${model.data!.first.content}',
            );
          }
          return model;
        } catch (parseError) {
          appLog('💥 Model parsing failed: $parseError');
          appLog('📄 Raw response data: ${responseData}');
          // Return empty model with error info
          return AllNoteModel(
            statusCode: 500,
            success: false,
            message: 'Failed to parse response: ${parseError.toString()}',
            data: [],
          );
        }
      } else {
        appLog('❌ API Error - Response is null');
        return AllNoteModel(
          statusCode: 500,
          success: false,
          message: 'API request failed - no data received',
          data: [],
        );
      }
    } catch (e) {
      appLog('💥 Repository Exception: $e');
      return AllNoteModel(
        statusCode: 500,
        success: false,
        message: 'Repository exception: ${e.toString()}',
        data: [],
      );
    }
  }

  //! Create Note
  Future<bool> createNote({
    required String projectId,
    String? content,
    List<File>? images,
    File? audio,
  }) async {
    appLog('========== CREATE NOTE REQUEST START ==========');
    appLog('Project ID: $projectId');
    appLog(
      'Content: ${content?.isNotEmpty == true ? "Yes (${content!.length} chars)" : "No"}',
    );
    appLog(
      'Images: ${images?.isNotEmpty == true ? "Yes (${images!.length} files)" : "No"}',
    );
    appLog('Audio: ${audio != null ? "Yes" : "No"}');

    try {
      final url = ApiUrls.createNote + projectId;
      appLog('API URL: $url');

      // Input validation
      if ((content?.trim().isEmpty ?? true) &&
          (images?.isEmpty ?? true) &&
          audio == null) {
        appLog(
          'ERROR: No content provided - at least one field must be non-empty',
        );
        return false;
      }

      // Create FormData
      FormData formData = FormData();

      // Add text content as simple field
      if (content?.trim().isNotEmpty == true) {
        formData.fields.add(MapEntry('content', content!.trim()));
        appLog(
          'Added content field: "${content.trim().substring(0, content.length > 50 ? 50 : content.length)}..."',
        );
      }

      // Process and add images
      if (images?.isNotEmpty == true) {
        List<MultipartFile> validImages = [];

        for (int i = 0; i < images!.length; i++) {
          final image = images[i];

          try {
            // Basic file validation
            if (!await image.exists()) {
              appLog('Warning: Image file does not exist: ${image.path}');
              continue;
            }

            final fileSize = await image.length();
            const maxFileSize = 10 * 1024 * 1024; // 10MB limit

            if (fileSize == 0) {
              appLog('Warning: Image file is empty: ${image.path}');
              continue;
            }

            if (fileSize > maxFileSize) {
              appLog(
                'Warning: Image file too large (${fileSize} bytes): ${image.path}',
              );
              continue;
            }

            // Extract filename
            final pathSegments = image.path.split(Platform.pathSeparator);
            final filename = pathSegments.isNotEmpty
                ? pathSegments.last
                : 'image_$i.jpg';

            if (filename.isEmpty) {
              appLog('Warning: Cannot determine filename for: ${image.path}');
              continue;
            }

            // Validate image extension
            final validExtensions = [
              '.jpg',
              '.jpeg',
              '.png',
              '.gif',
              '.bmp',
              '.webp',
            ];
            final hasValidExt = validExtensions.any(
              (ext) => filename.toLowerCase().endsWith(ext),
            );

            if (!hasValidExt) {
              appLog('Warning: Invalid image extension: $filename');
              continue;
            }

            // Determine MIME type based on extension
            String contentType = 'image/jpeg'; // default
            final ext = filename.toLowerCase();
            if (ext.endsWith('.png')) {
              contentType = 'image/png';
            } else if (ext.endsWith('.gif')) {
              contentType = 'image/gif';
            } else if (ext.endsWith('.bmp')) {
              contentType = 'image/bmp';
            } else if (ext.endsWith('.webp')) {
              contentType = 'image/webp';
            } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
              contentType = 'image/jpeg';
            }

            // Create MultipartFile with proper MIME type
            final multipartFile = await MultipartFile.fromFile(
              image.path,
              filename: filename,
              contentType: MediaType.parse(contentType),
            );

            appLog('Image MIME type: $contentType for $filename');

            validImages.add(multipartFile);
            appLog(
              'Added image: $filename (${(fileSize / 1024).toStringAsFixed(1)} KB)',
            );
          } catch (e) {
            appLog('Error processing image ${image.path}: $e');
            continue; // Skip this image but continue with others
          }
        }

        // Add valid images to form data
        if (validImages.isNotEmpty) {
          for (final img in validImages) {
            formData.files.add(MapEntry('images', img));
          }
          appLog('Total images added: ${validImages.length}');
        } else {
          appLog('Warning: No valid images found to upload');
        }
      }

      // Process and add audio
      if (audio != null) {
        try {
          // Basic audio file validation
          if (!await audio.exists()) {
            appLog('Warning: Audio file does not exist: ${audio.path}');
          } else {
            final fileSize = await audio.length();
            const maxAudioSize = 50 * 1024 * 1024; // 50MB limit

            if (fileSize == 0) {
              appLog('Warning: Audio file is empty: ${audio.path}');
            } else if (fileSize > maxAudioSize) {
              appLog(
                'Warning: Audio file too large (${fileSize} bytes): ${audio.path}',
              );
            } else {
              // Extract filename
              final pathSegments = audio.path.split(Platform.pathSeparator);
              final filename = pathSegments.isNotEmpty
                  ? pathSegments.last
                  : 'audio.m4a';

              if (filename.isNotEmpty) {
                // Validate audio extension
                final validAudioExts = [
                  '.mp3',
                  '.wav',
                  '.aac',
                  '.m4a',
                  '.ogg',
                  '.flac',
                ];
                final hasValidExt = validAudioExts.any(
                  (ext) => filename.toLowerCase().endsWith(ext),
                );
                if (hasValidExt) {
                  // Determine MIME type for audio
                  String audioContentType = 'audio/mpeg'; // default
                  final audioExt = filename.toLowerCase();
                  if (audioExt.endsWith('.mp3')) {
                    audioContentType = 'audio/mpeg';
                  } else if (audioExt.endsWith('.wav')) {
                    audioContentType = 'audio/wav';
                  } else if (audioExt.endsWith('.aac')) {
                    audioContentType = 'audio/aac';
                  } else if (audioExt.endsWith('.m4a')) {
                    audioContentType = 'audio/mp4';
                  } else if (audioExt.endsWith('.ogg')) {
                    audioContentType = 'audio/ogg';
                  } else if (audioExt.endsWith('.flac')) {
                    audioContentType = 'audio/flac';
                  }

                  final audioMultipart = await MultipartFile.fromFile(
                    audio.path,
                    filename: filename,
                    contentType: MediaType.parse(audioContentType),
                  );
                  formData.files.add(MapEntry('audio', audioMultipart));
                  appLog(
                    'Added audio: $filename (${(fileSize / 1024).toStringAsFixed(1)} KB) - MIME: $audioContentType',
                  );
                  appLog('Audio validation passed - ready for upload');
                  appLog('Audio field name: "$audio"');
                  appLog('Audio content type: $audioContentType');
                } else {
                  appLog('Warning: Invalid audio extension: $filename');
                }
              }
            }
          }
        } catch (e) {
          appLog('Error processing audio ${audio.path}: $e');
          // Continue without audio instead of failing completely
        }
      }
      // Final validation - ensure we have something to send
      if (formData.fields.isEmpty && formData.files.isEmpty) {
        appLog('ERROR: No valid data to send after processing');
        return false;
      }
      // Log what we're sending
      appLog('========== REQUEST SUMMARY ==========');
      appLog('URL: $url');
      appLog('Fields count: ${formData.fields.length}');
      for (var field in formData.fields) {
        appLog('  Field "${field.key}": "${field.value}"');
      }
      appLog('Files count: ${formData.files.length}');
      for (var file in formData.files) {
        appLog(
          '  File "${file.key}": ${file.value.filename} (${file.value.length} bytes)',
        );
      }
      appLog('====================================');

      // Make API call - interceptor will handle content-type automatically for FormData
      final responseData = await apiServices
          .apiPostServices(url: url, body: formData)
          .timeout(
            const Duration(seconds: 60), // Increased timeout for file uploads
            onTimeout: () {
              appLog('ERROR: Request timed out after 60 seconds');
              throw TimeoutException(
                'Request timeout',
                const Duration(seconds: 60),
              );
            },
          );
      // Process response
      appLog('Response received: ${responseData?.runtimeType}');
      if (responseData == null) {
        appLog(
          'ERROR: Null response received - this usually means non-200 status code',
        );
        appLog('Check server logs for the actual error response');
        appLog('This could be due to:');
        appLog('- Invalid file types or extensions');
        appLog('- File size limits exceeded');
        appLog('- Server-side validation failures');
        appLog('- Authentication or permission issues');
        return false;
      }

      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        appLog('Response data: $responseData');

        // Check for success indicators
        final success = responseData['success'];
        final message = responseData['message'] ?? 'Operation completed';

        // Multiple ways to determine success
        bool isSuccess = false;

        if (success == true || success == 'true' || success == 1) {
          isSuccess = true;
        } else if (responseData.containsKey('data') ||
            responseData.containsKey('id') ||
            responseData.containsKey('note_id')) {
          isSuccess = true;
        } else if (responseData.containsKey('statusCode')) {
          final statusCode = responseData['statusCode'];
          isSuccess = (statusCode == 200 || statusCode == 201);
        }

        if (isSuccess) {
          appLog('SUCCESS: Note created successfully - $message');
          return true;
        } else {
          appLog('ERROR: API returned failure - $message');
          appLog('Full error response: $responseData');
          // Check for specific audio validation errors
          if (message.toString().toLowerCase().contains('audio')) {
            appLog('AUDIO ERROR DETECTED: $message');
          }
          if (message.toString().toLowerCase().contains('invalid')) {
            appLog('VALIDATION ERROR DETECTED: $message');
          }
          return false;
        }
      } else if (responseData is String) {
        appLog('SUCCESS: String response received - $responseData');
        return true;
      } else {
        appLog('SUCCESS: Non-null response received');
        return true;
      }
    } catch (e, stackTrace) {
      appLog('EXCEPTION in createNote:');
      appLog('Error: $e');
      appLog('Type: ${e.runtimeType}');

      // Categorize errors for better debugging
      String errorCategory = 'Unknown';
      if (e is SocketException) {
        errorCategory = 'Network';
        appLog('Network connection failed - check internet connectivity');
      } else if (e is TimeoutException) {
        errorCategory = 'Timeout';
        appLog('Request timed out - server may be overloaded');
      } else if (e is FormatException) {
        errorCategory = 'Format';
        appLog('Data format error - check file formats and content');
      } else if (e.toString().contains('File size')) {
        errorCategory = 'FileSize';
        appLog('File size exceeded limits');
      } else if (e.toString().contains('Permission')) {
        errorCategory = 'Permission';
        appLog('File access permission denied');
      } else {
        appLog('Unexpected error occurred');
      }

      appLog('Error category: $errorCategory');
      appLog('Stack trace: ${stackTrace.toString().substring(0, 500)}...');
      appLog('========== CREATE NOTE FAILED ==========');

      return false;
    }
  }
}
