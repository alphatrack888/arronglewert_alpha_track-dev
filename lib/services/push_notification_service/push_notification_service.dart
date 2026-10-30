import 'dart:async';
import 'dart:io';

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/bottom_navigation/controller/bottom_navigation_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/project_details/controller/project_details_screen_controller.dart';
import 'package:alpha_track/screens/notification_screen/controller/notification_screen_controller.dart';
import 'package:alpha_track/services/repository/notification_repository/notification_repository.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/services/push_notification_service/device_register_paths.dart';
import 'package:alpha_track/services/push_notification_service/foreground_alert.dart';
import 'package:alpha_track/services/push_notification_service/notification_hygiene.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/utils/notification_routing/notification_routing.dart';
import 'package:alpha_track/utils/notification_routing/pending_notification_route.dart';
import 'package:alpha_track/widgets/getx_observer/getx_custome_observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  PushNotificationService._privateConstructor();
  static final PushNotificationService _instance =
      PushNotificationService._privateConstructor();
  static PushNotificationService get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final StorageServices _storageServices = StorageServices.instance;

  bool _listenersAttached = false;
  final _pendingNavigation = PendingNotificationRoute();

  Future<void> initialize() async {
    if (_listenersAttached) return;
    _listenersAttached = true;

    ForegroundAlertPresenter.bindTap(_handleLocalNotificationTap);
    await ForegroundAlertPresenter.consumePendingTap(_handleLocalNotificationTap);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      appLog("FCM token refreshed");
      if (_storageServices.getAccessToken().isEmpty) return;
      await _retryPendingDeregister();
      await _registerToken(newToken);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> registerCurrentToken() async {
    try {
      await _retryPendingDeregister();
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!_isGranted(settings)) {
        appLog(
          "Push permission not granted (${settings.authorizationStatus}) — continuing with in-app notifications only",
        );
        return;
      }

      final token = await _getReadyToken();
      if (token == null || token.isEmpty) {
        appLog("FCM token unavailable after permission grant");
        return;
      }

      await _registerToken(token);
    } catch (e) {
      errorLog("registerCurrentToken", e);
    }
  }

  Future<void> refreshRegistrationIfNeeded() async {
    if (_storageServices.getAccessToken().isEmpty) return;

    try {
      await _retryPendingDeregister();
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (!_isGranted(settings)) return;

      final token = await _getReadyToken();
      if (token == null || token.isEmpty) return;

      if (token != _storageServices.getRegisteredDeviceToken()) {
        await _registerToken(token);
      }
    } catch (e) {
      errorLog("refreshRegistrationIfNeeded", e);
    }
  }

  Future<String?> _getReadyToken() async {
    if (Platform.isIOS) {
      for (var attempt = 0; attempt < 10; attempt++) {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null && apns.isNotEmpty) {
          return FirebaseMessaging.instance.getToken();
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      appLog('APNs token not ready; registration will retry on resume');
      return null;
    }
    return FirebaseMessaging.instance.getToken();
  }

  void onAuthenticatedNavigationReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_storageServices.getAccessToken().isEmpty) return;
      _pendingNavigation.markReady();
      _openPendingNotification();
    });
  }

  void _openPendingNotification() {
    if (_storageServices.getAccessToken().isEmpty ||
        Get.key.currentState == null) {
      return;
    }
    final destination = _pendingNavigation.take();
    if (destination == null) return;
    _showDestination(destination);
    unawaited(_markOpenedRead(destination.notificationId));
  }

  void openNotification({
    String? category,
    String? notificationId,
    String? projectId,
  }) {
    _pendingNavigation.enqueue(
      destinationForNotification(
        category: category,
        notificationId: notificationId,
        projectId: projectId,
      ),
    );
    _openPendingNotification();
  }

  void _showDestination(NotificationDestination destination) {
    if (destination.projectId != null) {
      _showProject(destination.projectId!);
      return;
    }
    if (destination.opensTab) {
      _showTab(destination.tabIndex!);
      return;
    }
    if (Get.currentRoute == destination.route) return;
    Get.toNamed(destination.route);
  }

  void _showProject(String projectId) {
    if (Get.currentRoute == AppRoute.projectDetailsScreen &&
        Get.isRegistered<ProjectDetailsScreenController>()) {
      Get.find<ProjectDetailsScreenController>().syncProject(projectId);
      return;
    }
    Get.toNamed(
      AppRoute.projectDetailsScreen,
      arguments: {'projectId': projectId},
    );
  }

  void _showTab(int index) {
    final shellIsUnderCurrent =
        NavigationObserver.instance?.containsRoute(AppRoute.bottomNavigation) ??
            false;
    if (shellIsUnderCurrent &&
        Get.currentRoute != AppRoute.bottomNavigation) {
      Get.until(
        (route) => route.settings.name == AppRoute.bottomNavigation,
      );
    }
    // lazyPut creates the controller on first find. onInit does not run
    // again, so the tab has to be set here rather than via route arguments.
    Get.find<BottomNavScreenController>().onItemTapped(index);
  }

  Future<void> _markOpenedRead(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      if (kDemoMode) {
        _applyLoadedRead(id);
        return;
      }
      final saved = await NotificationRepository().markNotificationRead(id);
      if (!saved) return;
      _applyLoadedRead(id);
    } catch (e) {
      errorLog('_markOpenedRead', e);
    }
  }

  void _applyLoadedRead(String id) {
    if (!Get.isRegistered<NotificationScreenController>()) return;
    Get.find<NotificationScreenController>().applyReadLocally(id);
  }

  bool _isGranted(NotificationSettings settings) =>
      settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;

  Future<void> _registerToken(String token) async {
    if (_storageServices.getAccessToken().isEmpty) return;
    try {
      String appVersion = "";
      try {
        final info = await PackageInfo.fromPlatform();
        appVersion = info.version;
      } catch (e) {
        errorLog("PackageInfo.fromPlatform", e);
      }

      final response = await _apiServices.apiPostServices(
        url: ApiUrls.deviceRegister,
        body: {
          "token": token,
          "platform": Platform.isIOS ? "ios" : "android",
          if (appVersion.isNotEmpty) "appVersion": appVersion,
        },
      );

      if (response != null) {
        await _storageServices.setRegisteredDeviceToken(token);
        if (token == _storageServices.getPendingDeregisterToken()) {
          await _storageServices.clearPendingDeregister();
        }
        appLog("Device token registered");
      }
    } catch (e) {
      errorLog("_registerToken", e);
    }
  }

  /// One getToken, without the permission dialog. Null when the token is not ready.
  Future<String?> _peekToken() async {
    try {
      if (Platform.isIOS) {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns == null || apns.isEmpty) return null;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return null;
      return token;
    } catch (e) {
      errorLog("_peekToken", e);
      return null;
    }
  }

  Future<int?> _quietDeleteDevice(String token) {
    return _apiServices.quietDeleteStatus(
      url: DeviceRegisterPaths.deregisterUrl(
        ApiUrls.deviceDeregisterBase,
        token,
      ),
    );
  }

  Future<void> _applyDeleteDecision({
    required int? statusCode,
    required String savedUserId,
  }) async {
    final decision = pendingDeleteDecision(
      statusCode: statusCode,
      savedUserId: savedUserId,
      currentUserId: _storageServices.getUserId(),
    );
    if (pendingDeleteClears(decision)) {
      await _storageServices.clearPendingDeregister();
    }
  }

  /// Deletes a rotated logout token before the next register. A token that
  /// still matches the pending string is left for [_registerToken] to reassign.
  Future<void> _retryPendingDeregister() async {
    if (_storageServices.getAccessToken().isEmpty) return;
    final pending = _storageServices.getPendingDeregisterToken();
    if (pending.isEmpty) return;

    final current = await _peekToken();
    if (current != null && current == pending) return;

    final status = await _quietDeleteDevice(pending);
    await _applyDeleteDecision(
      statusCode: status,
      savedUserId: _storageServices.getPendingDeregisterUserId(),
    );
  }

  Future<void> deregisterCurrentToken() async {
    _pendingNavigation.reset();
    final token = _storageServices.getRegisteredDeviceToken();
    if (token.isEmpty) return;

    final userId = _storageServices.getUserId();
    await _storageServices.setPendingDeregister(token: token, userId: userId);
    try {
      final status = await _quietDeleteDevice(token);
      await _applyDeleteDecision(statusCode: status, savedUserId: userId);
    } catch (e) {
      errorLog("deregisterCurrentToken", e);
    }
  }

  static final Set<String> _recentlyShownNotificationIds = {};

  static bool claimForDisplay(String? notificationId) {
    if (notificationId == null || notificationId.isEmpty) return true;
    if (_recentlyShownNotificationIds.contains(notificationId)) return false;

    _recentlyShownNotificationIds.add(notificationId);
    Future.delayed(const Duration(seconds: 10), () {
      _recentlyShownNotificationIds.remove(notificationId);
    });
    return true;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    try {
      final notificationId = message.data['notificationId'];
      if (!claimForDisplay(notificationId)) {
        appLog(
          "Foreground push suppressed — already shown via socket: $notificationId",
        );
        return;
      }

      ForegroundAlertPresenter.present(foregroundNotificationPayload(
        title: message.notification?.title ?? 'New notification',
        body: message.notification?.body ?? '',
        notificationId: notificationId,
        category: message.data['category'],
        kind: message.data['kind'],
        projectId: message.data['projectId'],
      ));
    } catch (e) {
      errorLog("_handleForegroundMessage", e);
    }
  }

  void _handleLocalNotificationTap(Map<String, String> data) {
    _handleNotificationTap(RemoteMessage(data: data));
  }

  void _handleNotificationTap(RemoteMessage message) {
    try {
      appLog("Notification tapped: ${message.data}");
      openNotification(
        category: message.data['category'],
        notificationId: message.data['notificationId'],
        projectId: message.data['projectId'],
      );
    } catch (e) {
      errorLog("_handleNotificationTap", e);
    }
  }
}
