import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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
    return await showDialog<bool>(
          context: Get.context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.white100,
              title: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 28),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location Access Required',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alpha Track collects your location data to:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('  \u2022  ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          'Verify your on-site attendance and work location for project tracking.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('  \u2022  ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          'Record your location when you start and stop work sessions.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('  \u2022  ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          'Track location in the background during active work sessions to confirm job-site presence.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your location data is sent to our servers and used solely for attendance and project management purposes. Location tracking is only active during your work sessions.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Deny'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue500,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Allow'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // // Helper method to show dialog
  Future<bool> _showLocationServiceDialog() async {
    return await showDialog<bool>(
          context: Get.context!,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.white100,
              title: Text('Location Services Disabled'),
              content: Text(
                'Location services are turned off. Please enable location services to use this feature.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Open Settings'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Request location permissions with background support
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Request background location permission if needed
    if (permission == LocationPermission.whileInUse) {
      // For background location, you might need additional permission
      await Permission.locationAlways.request();
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
      print('Error getting current location: $e');
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
      // Ensure we have proper permissions
      await requestLocationPermission();

      // Check background permission specifically
      if (await Permission.locationAlways.isDenied) {
        await Permission.locationAlways.request();
      }

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
      print('Error getting last known position: $e');
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
        print('Location attempt ${i + 1} failed: $e');
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
