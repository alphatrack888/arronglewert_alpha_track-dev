import 'dart:io';

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/utils/notification_routing/notification_routing.dart';
import 'package:alpha_track/utils/notification_routing/pending_notification_route.dart';
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

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      appLog("FCM token refreshed");
      if (_storageServices.getAccessToken().isNotEmpty) {
        _registerToken(newToken);
      }
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> registerCurrentToken() async {
    try {
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
    final route = _pendingNavigation.take();
    if (route != null) Get.toNamed(route);
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
        appLog("Device token registered");
      }
    } catch (e) {
      errorLog("_registerToken", e);
    }
  }

  Future<void> deregisterCurrentToken() async {
    _pendingNavigation.reset();
    final token = _storageServices.getRegisteredDeviceToken();
    if (token.isEmpty) return;

    try {
      await _apiServices.apiDeleteServices(
        url: "${ApiUrls.deviceDeregisterBase}$token",
      );
    } catch (e) {
      errorLog("deregisterCurrentToken", e);
    } finally {
      await _storageServices.setRegisteredDeviceToken("");
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

      final title = message.notification?.title ?? 'New notification';
      final body = message.notification?.body ?? '';

      if (Get.isSnackbarOpen == false) {
        Get.snackbar(
          title,
          body,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.withValues(alpha: 0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
    } catch (e) {
      errorLog("_handleForegroundMessage", e);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    try {
      appLog("Notification tapped: ${message.data}");
      final route = routeForNotificationCategory(message.data['category']);
      _pendingNavigation.enqueue(route ?? AppRoute.notificationScreen);
      _openPendingNotification();
    } catch (e) {
      errorLog("_handleNotificationTap", e);
    }
  }
}
