import 'dart:io';

import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Channel shared with [MainActivity]. Android posts here; iOS keeps a snackbar.
const foregroundNotificationChannel = MethodChannel(
  'com.marcgelwertz.alphatrack/foreground_notification',
);

/// Fields sent to [ForegroundNotifications.show]. Empty optional fields are omitted.
Map<String, String> foregroundNotificationPayload({
  required String title,
  required String body,
  String? notificationId,
  String? category,
  String? kind,
  String? projectId,
}) {
  return {
    'title': title,
    'body': body,
    if (notificationId != null && notificationId.isNotEmpty)
      'notificationId': notificationId,
    if (category != null && category.isNotEmpty) 'category': category,
    if (kind != null && kind.isNotEmpty) 'kind': kind,
    if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
  };
}

/// Paused, hidden, and detached must not post: FCM already shows that banner.
bool lifecycleAllowsForegroundBanner(AppLifecycleState? state) {
  return state != AppLifecycleState.paused &&
      state != AppLifecycleState.hidden &&
      state != AppLifecycleState.detached;
}

/// Socket path only. A background socket event must not claim the id, or the
/// foreground push would be suppressed after the system banner already showed.
class SocketBannerPlan {
  final bool claim;
  final Map<String, String>? payload;

  const SocketBannerPlan._(this.claim, this.payload);

  factory SocketBannerPlan.decide({
    required AppLifecycleState? lifecycle,
    required String title,
    required String body,
    String? notificationId,
    String? category,
    String? kind,
    String? projectId,
  }) {
    if (!lifecycleAllowsForegroundBanner(lifecycle)) {
      return const SocketBannerPlan._(false, null);
    }
    return SocketBannerPlan._(
      true,
      foregroundNotificationPayload(
        title: title,
        body: body,
        notificationId: notificationId,
        category: category,
        kind: kind,
        projectId: projectId,
      ),
    );
  }
}

class ForegroundAlertPresenter {
  static void bindTap(void Function(Map<String, String> data) onTap) {
    foregroundNotificationChannel.setMethodCallHandler((call) async {
      if (call.method == 'onTap') onTap(_stringMap(call.arguments));
    });
  }

  /// One-shot delivery for a tap that arrived before this isolate was listening.
  static Future<void> consumePendingTap(
    void Function(Map<String, String> data) onTap,
  ) async {
    try {
      final pending = await foregroundNotificationChannel
          .invokeMethod<dynamic>('consumePendingTap');
      if (pending is Map) onTap(_stringMap(pending));
    } catch (e) {
      errorLog('consumePendingTap', e);
    }
  }

  /// Android posts a system notification. Other platforms keep the snackbar.
  /// A failed Android post is logged and does not fall back to a snackbar.
  static Future<void> present(Map<String, String> payload) async {
    if (Platform.isAndroid) {
      try {
        await foregroundNotificationChannel.invokeMethod<void>('show', payload);
      } catch (e) {
        errorLog('foreground notification', e);
      }
      return;
    }
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      payload['title'] ?? '',
      payload['body'] ?? '',
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  static Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry(key.toString(), value.toString()));
  }
}
