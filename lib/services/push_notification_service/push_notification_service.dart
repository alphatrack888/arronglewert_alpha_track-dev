import 'dart:io';

import 'package:alpha_track/utils/notification_routing/pending_notification_route.dart';

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/utils/notification_routing/notification_routing.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Required by firebase_messaging for background/terminated delivery: this
/// must be a top-level (or static) function, since it runs in its own
/// isolate with no access to app state. Left intentionally empty — the OS
/// already shows the notification automatically from the `notification`
/// payload when the app isn't in the foreground; this handler's only job is
/// to exist, so the plugin treats background delivery as wired up.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// FCM push lifecycle: permission, token registration/refresh/deregistration,
/// and foreground/tap handling. Mirrors AppSocketAllOperation's singleton
/// shape (services/socket_service/socket_service.dart) for consistency with
/// the existing codebase.
///
/// Division of responsibility with the existing Socket.IO system (Phase 11
/// plan's own recommendation): FCM is the delivery path for backgrounded/
/// killed app state (OS lock-screen notification, handled entirely by the
/// OS/FCM SDK — no code here needed for that case). The existing socket
/// system remains the source of truth for "app open" real-time UX. Both can
/// fire for the same backend event while the app is foregrounded (the
/// socket listener for notifications is only active while the Notifications
/// screen itself is mounted — see NotificationScreenController — so this
/// only actually collides there); [claimForDisplay] is the shared dedupe
/// gate both paths call through so only one visible banner ever appears per
/// event, regardless of which channel it arrived on first.
class PushNotificationService {
  PushNotificationService._privateConstructor();
  static final PushNotificationService _instance =
      PushNotificationService._privateConstructor();
  static PushNotificationService get instance => _instance;

  final ApiServices _apiServices = ApiServices.instance;
  final StorageServices _storageServices = StorageServices.instance;

  bool _listenersAttached = false;
  final _pendingNavigation = PendingNotificationRoute();

  /// Wires up the parts of FCM that don't depend on being logged in: the
  /// background handler, foreground/tap listeners, and token-refresh
  /// listening. Safe (and intended) to call once at app startup regardless
  /// of auth state — actually registering a token with the backend (which
  /// needs a bearer token) happens separately in [registerCurrentToken].
  Future<void> initialize() async {
    if (_listenersAttached) return;
    _listenersAttached = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      appLog("FCM token refreshed");
      // A refresh can fire before login (fresh install) or after logout
      // while the process is still alive — only push it to the backend if
      // there's actually a session to attach it to.
      if (_storageServices.getAccessToken().isNotEmpty) {
        _registerToken(newToken);
      }
    });

    // Cold start via a notification tap (app was fully killed).
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Requests notification permission and, if granted, registers the
  /// current FCM token with the backend. Call once right after a successful
  /// login. Denial is not an error — the app continues fine without push,
  /// falling back to the existing in-app socket notifications.
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

  /// Re-checks permission state and registers if it's now granted but
  /// wasn't before (or the token changed) — covers the case where the user
  /// denied at first, then granted it later from OS Settings outside the
  /// app. Call on every app resume while logged in.
  Future<void> refreshRegistrationIfNeeded() async {
    if (_storageServices.getAccessToken().isEmpty) return;

    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
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

  // Permission can be granted before iOS finishes APNs registration.
  Future<String?> _getReadyToken() async {
    if (Platform.isIOS) {
      for (var attempt = 0; attempt < 10; attempt++) {
        final token = await FirebaseMessaging.instance.getAPNSToken();
        if (token != null && token.isNotEmpty) {
          return FirebaseMessaging.instance.getToken();
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      appLog('APNs token not ready; registration will retry on resume');
      return null;
    }
    return FirebaseMessaging.instance.getToken();
  }

  /// Call after splash/login selects the authenticated home route.
  void onAuthenticatedNavigationReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_storageServices.getAccessToken().isEmpty) return;
      _pendingNavigation.markReady();
      _openPendingNotification();
    });
  }

  void _openPendingNotification() {
    if (_storageServices.getAccessToken().isEmpty ||
        Get.key.currentState == null)
      return;
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

  /// Call on logout, before clearing local auth state (the bearer token
  /// this call authenticates with is read fresh from storage at request
  /// time — see AppApi's interceptor). Deregisters this device so a
  /// shared/kiosk device stops receiving push for the user who just logged
  /// out; the next login on the same device registers its own token
  /// normally.
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
      // Cleared locally regardless of whether the network call succeeded —
      // this token is about to stop being this user's anyway, and retrying
      // a deregister for it later isn't useful.
      await _storageServices.setRegisteredDeviceToken("");
    }
  }

  // ── Foreground / tap handling, shared dedupe with the socket path ──────

  static final Set<String> _recentlyShownNotificationIds = {};

  /// Returns true (and claims it) if this notification id hasn't been shown
  /// in the last few seconds; false if something already claimed it. Call
  /// before showing ANY UI for a notification — from FCM's foreground
  /// handler below, and from NotificationScreenController's socket handler
  /// — so whichever channel delivers an event first wins and the other is
  /// suppressed, never both. An empty/missing id (e.g. a synthetic
  /// project/note event the socket handler builds locally, which has no
  /// server-side Notification document) always returns true — there's
  /// nothing for it to collide with.
  static bool claimForDisplay(String? notificationId) {
    if (notificationId == null || notificationId.isEmpty) return true;
    if (_recentlyShownNotificationIds.contains(notificationId)) return false;

    _recentlyShownNotificationIds.add(notificationId);
    // A short eviction window — this only guards the two channels for the
    // *same* event landing moments apart, not a long-lived "seen" ledger
    // (the notification list's own persisted isRead state is that).
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

  /// Background-to-foreground tap, and cold-start tap (via
  /// getInitialMessage in [initialize]). Routes by `category` in
  /// `message.data` (see time-tracker's notificationHelper.ts) via the
  /// same [routeForNotificationCategory] the in-app list uses — falls back
  /// to the notification list itself when there's no specific route for
  /// that category (or no category at all, e.g. an ad-hoc literal send).
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
