import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Direct method to pick from camera
  Future<File?> pickFromCamera(BuildContext context) async {
    try {
      log('🔍 Starting camera picker...');

      // Request camera permission first
      final permissionStatus = await Permission.camera.request();
      log('📱 Camera permission status: $permissionStatus');

      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDialog(context, 'Camera', 'camera');
        }
        return null;
      }

      if (permissionStatus.isGranted) {
        log('✅ Camera permission granted, opening camera...');
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1000,
          maxHeight: 1000,
        );

        if (pickedFile != null) {
          final file = File(pickedFile.path);
          if (await file.exists()) {
            log('✅ Camera image captured: ${pickedFile.path}');
            return file;
          } else {
            log('❌ Camera image file does not exist: ${pickedFile.path}');
            if (context.mounted) {
              _showErrorDialog(context, 'Camera Error',
                  'Captured image file is invalid or missing.');
            }
            return null;
          }
        } else {
          log('❌ No image captured from camera');
          return null;
        }
      }
      return null;
    } catch (e) {
      log('❌ Camera error: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Camera Error', e.toString());
      }
      return null;
    }
  }

  /// Direct method to pick from gallery
  Future<File?> pickFromGallery(BuildContext context) async {
    try {
      log('🔍 Starting gallery picker...');

      // Request storage permission
      bool hasPermission = await _requestStoragePermission();
      log('📱 Storage permission granted: $hasPermission');

      if (!hasPermission) {
        if (context.mounted) {
          _showPermissionDialog(context, 'Storage', 'photos and media');
        }
        return null;
      }

      log('✅ Storage permission granted, opening gallery...');
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          log('✅ Gallery image selected: ${pickedFile.path}');
          return file;
        } else {
          log('❌ Gallery image file does not exist: ${pickedFile.path}');
          if (context.mounted) {
            _showErrorDialog(context, 'Gallery Error',
                'Selected image file is invalid or missing.');
          }
          return null;
        }
      } else {
        log('❌ No image selected from gallery');
        return null;
      }
    } catch (e) {
      log('❌ Gallery error: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Gallery Error', e.toString());
      }
      return null;
    }
  }

  /// Show choice dialog with direct buttons - PROPERLY FIXED VERSION
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                      child:
                          const Icon(Icons.photo_library, color: Colors.green),
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

  /// Request storage permission based on Android version
  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isIOS) {
        // iOS handles permissions automatically
        return true;
      }

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkVersion = androidInfo.version.sdkInt;
        log('📱 Android SDK Version: $sdkVersion');

        if (sdkVersion >= 33) {
          // Android 13+ - use photos permission
          final status = await Permission.photos.request();
          log('📱 Photos permission: $status');
          return status.isGranted;
        } else {
          // Android < 13 - use storage permission
          final status = await Permission.storage.request();
          log('📱 Storage permission: $status');
          return status.isGranted;
        }
      }
      return false;
    } catch (e) {
      log('❌ Permission request error: $e');
      return false;
    }
  }

  /// Show permission dialog
  void _showPermissionDialog(
      BuildContext context, String permissionType, String feature) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
            'Please allow access to $feature in your device settings to use this feature.'),
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

  /// Test individual components
  Future<void> debugPermissions() async {
    log('🧪 === DEBUGGING PERMISSIONS ===');

    // Test camera permission
    final cameraStatus = await Permission.camera.status;
    log('📱 Camera Permission: $cameraStatus');

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      log('📱 Android Version: ${androidInfo.version.release} (SDK: ${androidInfo.version.sdkInt})');

      if (androidInfo.version.sdkInt >= 33) {
        final photosStatus = await Permission.photos.status;
        log('📱 Photos Permission: $photosStatus');
      } else {
        final storageStatus = await Permission.storage.status;
        log('📱 Storage Permission: $storageStatus');
      }
    }

    log('🧪 === END DEBUG ===');
  }
}