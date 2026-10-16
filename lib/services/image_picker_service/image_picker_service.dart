import 'dart:developer';
import 'dart:io';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

/// SDK level at which Android uses [Permission.photos] instead of [Permission.storage].
const int androidGalleryPhotosPermissionMinSdk = 33;

/// Photo Picker on API 33+ needs no runtime storage/photos permission before pick.
bool shouldRequestGalleryPermissionBeforePick(int sdkInt) =>
    sdkInt < androidGalleryPhotosPermissionMinSdk;

/// Whether [permission_handler] status allows opening the gallery picker.
bool isGalleryPermissionSufficient(PermissionStatus status) =>
    status.isGranted || status.isLimited;

class _GalleryPermissionRequestResult {
  const _GalleryPermissionRequestResult({
    required this.canPick,
    this.permanentlyDenied = false,
    this.permissionLabel = 'Storage',
  });

  final bool canPick;
  final bool permanentlyDenied;
  final String permissionLabel;
}

/// Copies picker output into app temp storage (needed for Android limited photo access).
Future<File?> materializePickedImageFile(XFile picked) async {
  try {
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      log('❌ Picked image has no readable bytes');
      return null;
    }
    final rawName =
        picked.name.isNotEmpty ? picked.name : picked.path.split('/').last;
    final safeName = rawName.contains('.') ? rawName : '$rawName.jpg';
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/gallery_${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  } catch (e) {
    log('❌ Failed to materialize picked image: $e');
    return null;
  }
}

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
          final file = await materializePickedImageFile(pickedFile);
          if (file != null) {
            log('✅ Camera image ready for upload: ${file.path}');
            return file;
          }
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Camera Error',
              'galleryImageUnreadable'.tr,
            );
          }
          return null;
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

      final permissionResult = await _requestGalleryPermission();
      log(
        '📱 Gallery permission: canPick=${permissionResult.canPick} '
        'permanentlyDenied=${permissionResult.permanentlyDenied}',
      );

      if (!permissionResult.canPick) {
        if (permissionResult.permanentlyDenied && context.mounted) {
          _showPermissionDialog(
            context,
            permissionResult.permissionLabel,
            permissionResult.permissionLabel.toLowerCase(),
          );
        }
        return null;
      }

      log('✅ Opening gallery picker...');
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        final file = await materializePickedImageFile(pickedFile);
        if (file != null) {
          log('✅ Gallery image ready for upload: ${file.path}');
          return file;
        }
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Gallery Error',
            'galleryImageUnreadable'.tr,
          );
        }
        return null;
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
                    subtitle: Text('chooseFromGallery'.tr),
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

  Future<_GalleryPermissionRequestResult> _requestGalleryPermission() async {
    try {
      if (Platform.isIOS) {
        return const _GalleryPermissionRequestResult(canPick: true);
      }

      if (!Platform.isAndroid) {
        return const _GalleryPermissionRequestResult(canPick: false);
      }

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;
      log('📱 Android SDK Version: $sdkVersion');

      if (!shouldRequestGalleryPermissionBeforePick(sdkVersion)) {
        log('✅ API 33+: using system Photo Picker without broad photos permission');
        return const _GalleryPermissionRequestResult(canPick: true);
      }

      const label = 'Storage';
      final status = await Permission.storage.request();
      log('📱 Gallery storage permission: $status');

      if (status.isGranted) {
        return const _GalleryPermissionRequestResult(
          canPick: true,
          permissionLabel: label,
        );
      }

      return _GalleryPermissionRequestResult(
        canPick: false,
        permanentlyDenied: status.isPermanentlyDenied,
        permissionLabel: label,
      );
    } catch (e) {
      log('❌ Permission request error: $e');
      return const _GalleryPermissionRequestResult(canPick: false);
    }
  }

  /// Show permission dialog
  void _showPermissionDialog(
      BuildContext context, String permissionType, String feature) async {
    if (!context.mounted) return;

    final confirmed = await DsDialog.confirm(
      title: 'permissionRequiredFor'.trParams({'type': permissionType}),
      message:
          'allowAccessInSettings'.trParams({'feature': feature}),
      confirmLabel: 'Settings',
      cancelLabel: 'Cancel',
      tone: DsDialogTone.warning,
      icon: LucideIcons.lock,
      destructive: false,
    );
    if (confirmed) {
      openAppSettings(); // Opens app settings
    }
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    if (!context.mounted) return;

    DsDialog.alert(
      title: title,
      message: message,
      tone: DsDialogTone.danger,
      icon: LucideIcons.triangleAlert,
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

      if (shouldRequestGalleryPermissionBeforePick(androidInfo.version.sdkInt)) {
        final storageStatus = await Permission.storage.status;
        log('📱 Storage Permission: $storageStatus');
      } else {
        log('📱 Gallery: Photo Picker path (no broad photos permission)');
      }
    }

    log('🧪 === END DEBUG ===');
  }
}
