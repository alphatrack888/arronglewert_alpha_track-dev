import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  // Stream for continuous location updates
  Stream<Position>? positionStream;

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      appLog('Location services are disabled.');

      // Show dialog to user and prompt them to enable location services
      bool shouldOpenSettings = await _showLocationServiceDialog();
      if (shouldOpenSettings) {
        await Geolocator.openLocationSettings();
      }
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    appLog('Current permission status: $permission');

    if (permission == LocationPermission.denied) {
      // Show prominent disclosure before requesting permission
      bool userConsented = await _showLocationDisclosureDialog();
      if (!userConsented) {
        appLog('User declined location disclosure');
        return;
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        appLog('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      appLog('Location permissions are permanently denied.');
      await Geolocator.openAppSettings();
      return;
    }

    appLog('Location permission granted: $permission');
  }

  /// Prominent disclosure dialog for location data collection (Google Play policy requirement)
  Future<bool> _showLocationDisclosureDialog() async {
    return await Get.dialog<bool>(
          DsDialog(
            title: 'locationAccessRequired'.tr,
            tone: DsDialogTone.info,
            icon: LucideIcons.mapPin,
            barrierDismissible: false,
            confirmLabel: 'allow'.tr,
            cancelLabel: 'deny'.tr,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'locCollectsTo'.tr,
                  style: AppTextStyles.bodySemibold,
                ),
                const SizedBox(height: 12),
                _disclosureBullet(
                    'locBullet1'.tr),
                _disclosureBullet(
                    'locBullet2'.tr),
                _disclosureBullet(
                    'locBullet3'.tr),
                const SizedBox(height: 12),
                Text(
                  'locFooter'.tr,
                  style: AppTextStyles.caption.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.25),
        ) ??
        false;
  }

  Widget _disclosureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  // // Helper method to show dialog
  Future<bool> _showLocationServiceDialog() async {
    return await DsDialog.confirm(
      title: 'locationServicesDisabled'.tr,
      message:
          'locationServicesDisabledBody'.tr,
      confirmLabel: 'openSettings'.tr,
      cancelLabel: 'Cancel',
      tone: DsDialogTone.warning,
      icon: LucideIcons.mapPin,
      destructive: false,
    );
  }

  /// Request while-in-use location permission.
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current location with high accuracy
  Future<Position?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }

      // Check and request permissions
      LocationPermission permission = await requestLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied.');
      }

      // Get current position with high accuracy settings
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: timeout,
      );

      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Get location stream for continuous updates with high accuracy
  Stream<Position> getLocationStream({
    int distanceFilter = 0, // 0 means get all updates
    Duration interval = const Duration(seconds: 5),
  }) {
    if (positionStream != null) {
      return positionStream!;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Get updates for any movement
      timeLimit: Duration(seconds: 30),
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    return positionStream!;
  }

  /// Start background location tracking
  Future<void> startBackgroundLocationTracking() async {
    try {
      // While-in-use only. Clock actions take one fix while the app is open.
      await requestLocationPermission();

      // Start listening to location updates
      getLocationStream().listen(
        (Position position) {
          // Handle location updates here
          _handleLocationUpdate(position);
        },
        onError: (error) {
          appLog('Background location error: $error');
        },
      );
    } catch (e) {
      appLog('Error starting background location tracking: $e');
    }
  }

  /// Handle location updates (customize this method based on your needs)
  void _handleLocationUpdate(Position position) {
    // Store location in local database, send to server, etc.
    appLog('New location: ${position.latitude}, ${position.longitude}');
    appLog('Accuracy: ${position.accuracy} meters');
    appLog('Timestamp: ${position.timestamp}');

    // You can add your custom logic here:
    // - Save to local database
    // - Send to your backend server
    // - Update UI if app is in foreground
    // - Trigger geofencing checks
  }

  /// Stop background location tracking
  void stopBackgroundLocationTracking() {
    positionStream = null;
  }

  /// Calculate distance between two positions
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get last known position from cache
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  /// Check if location permissions are granted for background usage
  Future<bool> hasBackgroundLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always;
  }

  /// Get location with retry mechanism
  Future<Position?> getCurrentLocationWithRetry({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final position = await getCurrentLocation();
        if (position != null) {
          return position;
        }
      } catch (e) {
        debugPrint('Location attempt ${i + 1} failed: $e');
        if (i < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      }
    }
    return null;
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
