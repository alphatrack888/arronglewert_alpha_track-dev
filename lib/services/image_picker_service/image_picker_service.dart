import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<File?> pickFromCamera(BuildContext context) =>
      _pickSingle(context, ImageSource.camera);

  Future<File?> pickFromGallery(BuildContext context) =>
      _pickSingle(context, ImageSource.gallery);

  // System pickers grant access only to selected files. Do not gate these
  // calls on broad photo/storage permissions. Full metadata is not needed.
  Future<List<XFile>> pickMultipleImages() =>
      _picker.pickMultiImage(requestFullMetadata: false);

  static String errorMessage(Object error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'camera_access_denied':
        case 'camera_access_denied_without_prompt':
          return 'Camera access is disabled. You can enable it in app settings.';
        case 'camera_access_restricted':
          return 'Camera access is restricted on this device.';
        case 'photo_access_denied':
        case 'photo_access_denied_without_prompt':
          return 'Photo access is disabled. Check your app settings.';
        case 'photo_access_restricted':
          return 'Photo access is restricted on this device.';
        case 'already_active':
          return 'An image picker is already open.';
      }
    }
    return 'Could not open or read the image. Please try again.';
  }

  Future<File?> _pickSingle(BuildContext context, ImageSource source) async {
    try {
      // The plugin handles iOS camera authorization and Android camera intents.
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
        requestFullMetadata: false,
      );
      if (picked == null) return null; // User cancelled.
      final file = File(picked.path);
      if (!await file.exists()) {
        throw const FileSystemException('Selected image is unavailable');
      }
      return file;
    } catch (error) {
      log('Image selection failed', error: error);
      if (!context.mounted) return null;
      if (error is PlatformException &&
          (error.code == 'camera_access_denied' ||
              error.code == 'camera_access_denied_without_prompt')) {
        _showPermissionDialog(context, 'Camera', 'camera');
      } else if (error is PlatformException &&
          (error.code == 'photo_access_denied' ||
              error.code == 'photo_access_denied_without_prompt')) {
        _showPermissionDialog(context, 'Photos', 'photos');
      } else {
        _showErrorDialog(context, 'Image selection', errorMessage(error));
      }
      return null;
    }
  }

  /// Choose the native camera or gallery picker.
  Future<File?> pickImage(BuildContext context) async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Select Image Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Camera Option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.blue),
                    ),
                    title: const Text('Camera'),
                    subtitle: const Text('Take a new photo'),
                    onTap: () {
                      Navigator.pop(context, 'camera');
                    },
                  ),

                  const SizedBox(height: 10),

                  // Gallery Option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('Gallery'),
                    subtitle: const Text('Choose from gallery'),
                    onTap: () {
                      Navigator.pop(context, 'gallery');
                    },
                  ),

                  const SizedBox(height: 20),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!context.mounted) return null;

      // Handle the result after bottom sheet is closed
      if (result == 'camera') {
        return await pickFromCamera(context);
      } else if (result == 'gallery') {
        return await pickFromGallery(context);
      }

      return null;
    } catch (e) {
      log('❌ Dialog error: $e');
      return null;
    }
  }

  /// Show permission dialog
  void _showPermissionDialog(
    BuildContext context,
    String permissionType,
    String feature,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'Please allow access to $feature in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Opens app settings
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
