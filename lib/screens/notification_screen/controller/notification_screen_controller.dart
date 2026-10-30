import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/screens/notification_screen/notification_inbox_pagination.dart';
import 'package:alpha_track/screens/notification_screen/notification_locale.dart';
import 'package:alpha_track/services/push_notification_service/foreground_alert.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/repository/notification_repository/notification_repository.dart';
import 'package:alpha_track/services/socket_service/socket_channel_names.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreenController extends GetxController {
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  final AppSocketAllOperation socketAllOperation =
      AppSocketAllOperation.instance;
  final StorageServices storageServices = StorageServices.instance;
  // Observable variables
  var isLoading = false.obs;
  var notifications = <Datum>[].obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = false.obs;
  String? _loadedLocale;

  String get _notificationLocale =>
      NotificationLocale.normalize(storageServices.getLanguage());

  // Controllers
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _setupScrollListener();
    registerNotificationSocketListeners();
  }

  @override
  void onClose() {
    scrollController.dispose();
    // Clean up socket listeners when controller is disposed
    _cleanupSocketListeners();
    super.onClose();
  }

  // Setup scroll listener for pagination
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      final position = scrollController.position;
      if (!NotificationInboxPagination.shouldLoadMore(
        pixels: position.pixels,
        maxScrollExtent: position.maxScrollExtent,
      )) {
        return;
      }
      if (hasMoreData.value && !isLoading.value) {
        loadMoreNotifications();
      }
    });
  }
  String? _registeredSocketUserId;

  /// Registers notification + new-project inbox socket channels (Phase 2).
  void registerNotificationSocketListeners() {
    try {
      final userId = storageServices.getUserId();
      if (userId.isEmpty) return;
      if (_registeredSocketUserId == userId) return;
      _registeredSocketUserId = userId;

      socketAllOperation.connectIfAuthenticated();
      appLog(
        'Socket subscribe channels: ${SocketChannelNames.notificationChannel(userId)}, '
        '${SocketChannelNames.newProjectChannel(userId)} (userId=$userId)',
      );
      socketAllOperation.readEvent(
        event: SocketChannelNames.notificationChannel(userId),
        handler: _handleNotification,
      );
      socketAllOperation.readEvent(
        event: SocketChannelNames.newProjectChannel(userId),
        handler: _handleNewProject,
      );
      // Deferred: updatedProject::<authId>, note::<projectId> — see BACKEND_INTEGRATION_PLAN Phase 2.
    } catch (e) {
      appLog("Error registerNotificationSocketListeners: $e");
    }
  }
  //! Socket Event Handler - Real-time notification updates
  void _handleNotification(dynamic data) {
    appLog("Notification received: $data");
    try {
      if (data is Map) {
        final localized = NotificationLocale.apply(
          Map<String, dynamic>.from(data),
          storageServices.getLanguage(),
        );
        final newNotification = Datum.fromJson(localized);
        
        // Add to the beginning of the list for real-time updates
        _addNewNotificationOptimized(newNotification);
        
        // Optional: Show a snackbar or toast for new notifications
        _showNewNotificationIndicator(newNotification);
      }
    } catch (e) {
      appLog("Error handling notification: $e");
    }
  }

  //! Socket Event Handler - New project notifications
  void _handleNewProject(dynamic data) {
    appLog("New Project received: $data");
    try {
      if (data != null) {
        // Create a notification object for new project
        final projectNotification = _createProjectNotification(
          data, 
          'newProjectCreated'.tr, 
          'newProjectCreatedBody'.tr
        );
        if (projectNotification != null) {
          _addNewNotificationOptimized(projectNotification);
        }
      }
    } catch (e) {
      appLog("Error handling new project: $e");
    }
  }

  // Fetch initial notifications
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    // TEMPORARY demo mode — show sample notifications without a backend.
    if (kDemoMode) {
      notifications.assignAll(DemoData.notifications.data?.data ?? []);
      hasError.value = false;
      isLoading.value = false;
      hasMoreData.value = false;
      return;
    }
    try {
      final locale = _notificationLocale;
      _loadedLocale = locale;
      if (isRefresh) {
        currentPage.value = 1;
        notifications.clear();
      }

      isLoading.value = true;
      hasError.value = false;

      final response = await _notificationRepository.fetchAlltheNotificaton(
        page: currentPage.value,
        locale: locale,
      );

      if (response.success == true && response.data != null) {
        final newNotifications = response.data!.data ?? [];
        final merged = NotificationInboxPagination.mergePageIntoList(
          existing: notifications.toList(),
          pageItems: newNotifications,
          page: currentPage.value,
          isRefresh: isRefresh,
        );
        notifications.assignAll(merged);
        // Update pagination info
        if (response.data!.meta != null) {
          totalPages.value = response.data!.meta!.totalPages ?? 1;
          hasMoreData.value = currentPage.value < totalPages.value;
        }
        appLog(
          "Notifications loaded successfully: ${notifications.length} items",
        );
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? 'failedLoadNotifications'.tr;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'errLoadNotifications'.tr;
      appLog("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (currentPage.value >= totalPages.value) return;

    try {
      currentPage.value++;
      final response = await _notificationRepository.fetchAlltheNotificaton(
        page: currentPage.value,
        locale: _notificationLocale,
      );

      if (response.success == true && response.data != null) {
        final newNotifications = response.data!.data ?? [];
        notifications.addAll(newNotifications);
        hasMoreData.value = currentPage.value < totalPages.value;
      }
    } catch (e) {
      currentPage.value--; // Rollback page increment on error
      appLog("Error loading more notifications: $e");
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications(isRefresh: true);
  }

  /// Reloads the list after the phone language changes. The controller stays
  /// alive, so opening the screen again does not fetch on its own.
  Future<void> reloadIfLocaleChanged() async {
    if (kDemoMode) return;
    if (_loadedLocale == _notificationLocale) return;
    await refreshNotifications();
  }

  /// Updates a row that is already loaded. Does not call the server.
  void applyReadLocally(String id) {
    final index = notifications.indexWhere((notification) => notification.id == id);
    if (index == -1) return;
    if (notifications[index].isRead == true) return;
    notifications[index].isRead = true;
    notifications.refresh();
  }

  Future<void> markAsRead(String? id) async {
    if (id == null) return;
    if (kDemoMode) {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
      }
      return;
    }

    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (notifications[index].isRead == true) return;

    notifications[index].isRead = true;
    notifications.refresh();

    final success = await _notificationRepository.markNotificationRead(id);
    if (!success) {
      notifications[index].isRead = false;
      notifications.refresh();
      AppSnackBar.error('errLoadNotifications'.tr);
    }
  }

  Future<void> markAllAsRead() async {
    final hasUnread =
        notifications.any((n) => n.isRead != true);
    if (!hasUnread) return;

    if (kDemoMode) {
      for (final n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
      return;
    }

    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();

    final success = await _notificationRepository.markAllNotificationsRead();
    if (!success) {
      await refreshNotifications();
      AppSnackBar.error('errLoadNotifications'.tr);
    }
  }

  // Format notification time
  String formatNotificationTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'justNow'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Delete notification (local only)
  void deleteNotification(String notificationId) {
    try {
      notifications.removeWhere(
        (notification) => notification.id == notificationId,
      );
      notifications.refresh();
      appLog("Notification deleted locally: $notificationId");
    } catch (e) {
      appLog("Error deleting notification: $e");
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    notifications.clear();
  }

  //! Optimized methods for real-time notification updates
  
  /// Adds a new notification to the list in an optimized way
  void _addNewNotificationOptimized(Datum newNotification) {
    try {
      // Check if notification already exists to avoid duplicates
      final existingIndex = notifications.indexWhere(
        (notification) => notification.id == newNotification.id,
      );
      
      if (existingIndex == -1) {
        // Add to the beginning of the list for newest-first display
        notifications.insert(0, newNotification);
        
        // Maintain a reasonable list size for performance (optional)
        if (notifications.length > 100) {
          notifications.removeRange(100, notifications.length);
        }
        
        // Trigger UI update
        notifications.refresh();
        
        appLog("New notification added: ${newNotification.title}");
      } else {
        // Update existing notification if needed
        notifications[existingIndex] = newNotification;
        notifications.refresh();
        appLog("Notification updated: ${newNotification.title}");
      }
    } catch (e) {
      appLog("Error adding notification: $e");
    }
  }

  /// Creates a project notification from socket data
  Datum? _createProjectNotification(dynamic data, String title, String body) {
    try {
      return Datum(
        id: data['_id'] ?? data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Add other fields as needed based on your data structure
      );
    } catch (e) {
      appLog("Error creating project notification: $e");
      return null;
    }
  }

  /// Shows a visual indicator for new notifications (optional)
  void _showNewNotificationIndicator(Datum notification) {
    try {
      final plan = SocketBannerPlan.decide(
        lifecycle: WidgetsBinding.instance.lifecycleState,
        title: notification.title ?? 'newNotification'.tr,
        body: notification.body ?? 'newNotificationBody'.tr,
        notificationId: notification.id,
        category: notification.category,
        projectId: notification.projectId,
      );
      if (!plan.claim || plan.payload == null) return;
      if (!PushNotificationService.claimForDisplay(notification.id)) return;
      ForegroundAlertPresenter.present(plan.payload!);
    } catch (e) {
      appLog("Error showing notification indicator: $e");
    }
  }


  /// Remove notification by ID (for real-time deletion)
  void removeNotificationById(String notificationId) {
    try {
      final index = notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );
      
      if (index != -1) {
        notifications.removeAt(index);
        notifications.refresh();
        appLog("Notification removed: $notificationId");
      }
    } catch (e) {
      appLog("Error removing notification: $e");
    }
  }

  /// Cleanup socket listeners to prevent memory leaks
   void _cleanupSocketListeners() {
     try {
       final userId = _registeredSocketUserId ?? storageServices.getUserId();
       if (userId.isNotEmpty) {
         socketAllOperation.removeHandlersForEvent(
           SocketChannelNames.notificationChannel(userId),
         );
         socketAllOperation.removeHandlersForEvent(
           SocketChannelNames.newProjectChannel(userId),
         );
         appLog("Notification socket listener removed for user: $userId");
       }
       _registeredSocketUserId = null;
     } catch (e) {
       appLog("Error cleaning up socket listeners: $e");
     }
   }

   /// Reconnect socket and re-establish listeners (useful for network recovery)
   void reconnectSocket() {
     try {
       socketAllOperation.reconnect();
       // Re-establish listeners after reconnection
       Future.delayed(const Duration(seconds: 1), () {
         registerNotificationSocketListeners();
       });
     } catch (e) {
       appLog("Error reconnecting socket: $e");
     }
   }

   /// Check socket connection status
   bool get isSocketConnected => socketAllOperation.isConnected;
}
