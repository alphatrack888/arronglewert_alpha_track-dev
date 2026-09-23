import 'dart:async';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxController {
  RxList<ConnectivityResult> connectionStatus = <ConnectivityResult>[].obs;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  
  // Store the previous route to navigate back when internet is restored
  String? _previousRoute;
  bool _wasOnErrorScreen = false;

  Future<void> initConnectivity() async {
    try {
      List<ConnectivityResult> result = await connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      connectivitySubscription = connectivity.onConnectivityChanged.listen((event) {
        _updateConnectionStatus(event);
      });
    } on PlatformException catch (e) {
      errorLog('Couldn\'t check connectivity status', e);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    try {
      connectionStatus.value = result;
      connectionStatus.refresh();
      
      if (result.contains(ConnectivityResult.none)) {
        // No internet connection - navigate to error screen
        _navigateToErrorScreen();
      } else {
        // Internet connection restored - navigate back if we were on error screen
        _handleInternetRestored();
      }
    } catch (e) {
      errorLog("_updateConnectionStatus", e);
    }
  }

  void _navigateToErrorScreen() {
    Future.microtask(() {
      if (Get.isRegistered<GetMaterialApp>()) {
        // Only store the current route if we're not already on error screen
        if (Get.currentRoute != AppRoute.errorScreen) {
          _previousRoute = Get.currentRoute;
        }
        _wasOnErrorScreen = true;
        Get.offAllNamed(AppRoute.errorScreen);
      }
    });
  }

  void _handleInternetRestored() {
    if (_wasOnErrorScreen && _previousRoute != null) {
      Future.microtask(() {
        if (Get.isRegistered<GetMaterialApp>() && Get.currentRoute == AppRoute.errorScreen) {
          // Navigate back to the previous route
          String routeToNavigate = _previousRoute ?? AppRoute.splashScreen;
          _wasOnErrorScreen = false;
          _previousRoute = null;
          Get.offAllNamed(routeToNavigate);
        }
      });
    }
  }

  // Method to set previous route from middleware
  void setPreviousRoute(String route) {
    if (Get.currentRoute != AppRoute.errorScreen) {
      _previousRoute = route;
    }
  }

  // Getter to check if device is connected to internet
  bool get isConnected => !connectionStatus.contains(ConnectivityResult.none);

  // Getter for the connectivity stream (for use in controllers if needed)
  Stream<List<ConnectivityResult>> get onConnectivityChanged => connectivity.onConnectivityChanged;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
  }

  @override
  void onClose() {
    connectivitySubscription.cancel();
    super.onClose();
  }
}