import 'dart:async';

import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/services/connectivity_services/connectivity_service.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/repository/notification_repository/notification_repository.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  // Server-computed (Phase 12) — the single source of truth for the bell
  // badge, never derived by counting !isRead over whatever page happens to
  // be loaded locally.
  var unreadCount = 0.obs;

  // Controllers
  final ScrollController scrollController = ScrollController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _setupScrollListener();
    socketCalling();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    // Clean up socket listeners when controller is disposed
    _cleanupSocketListeners();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Replays any mark-read/mark-all-read actions that were queued while
  /// offline (see markAsRead/markAllAsRead) as soon as connectivity comes
  /// back — this is the actual "sync when connectivity returns" half of the
  /// offline edge case, not just "don't crash while offline".
  void _setupConnectivityListener() {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      _connectivitySubscription = connectivityService.onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          _syncPendingOfflineActions();
        }
      });
    } catch (e) {
      appLog("Error setting up connectivity listener: $e");
    }
  }

  Future<void> _syncPendingOfflineActions() async {
    try {
      final pendingAll = storageServices.getPendingMarkAllRead();
      final pendingIds = storageServices.getPendingMarkReadIds();
      if (!pendingAll && pendingIds.isEmpty) return;

      bool anySynced = false;

      if (pendingAll) {
        final success = await _notificationRepository.markAllNotificationsRead();
        if (success) {
          await storageServices.setPendingMarkAllRead(false);
          await storageServices.clearPendingMarkReadIds();
          anySynced = true;
        }
      } else {
        final stillPending = <String>[];
        for (final id in pendingIds) {
          final success = await _notificationRepository.markNotificationRead(id);
          if (!success) stillPending.add(id);
        }
        if (stillPending.length != pendingIds.length) anySynced = true;
        await storageServices.clearPendingMarkReadIds();
        for (final id in stillPending) {
          await storageServices.addPendingMarkReadId(id);
        }
      }

      if (anySynced) {
        appLog("Offline mark-read queue synced");
        AppSnackBar.success(AppString.offlineChangesSynced.tr);
        // The server is the source of truth for isRead/unreadCount — a
        // fresh fetch after syncing avoids any local state drifting from
        // what actually got persisted (some queued ids can fail to sync
        // individually, e.g. a notification deleted server-side since).
        await fetchNotifications(isRefresh: true);
      }
    } catch (e) {
      appLog("Error syncing pending offline actions: $e");
    }
  }

  // Setup scroll listener for pagination
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMoreData.value && !isLoading.value) {
          loadMoreNotifications();
        }
      }
    });
  }
  //! Socket Calling
  void socketCalling() async {
    try{
      var userId = storageServices.getUserId();
      if(userId.isNotEmpty){
        socketAllOperation.readEvent(event: "notification::$userId", handler: _handleNotification);
        socketAllOperation.readEvent(event: "newProject::$userId", handler: _handleNewProject);
        socketAllOperation.readEvent(event: "updateProject::$userId", handler: _handleUpdateProject);
        socketAllOperation.readEvent(event: "removeProject::$userId", handler: _handleDeleteProject);
        socketAllOperation.readEvent(event: "note::$userId", handler: _handleDeleteNote);
      }

    } catch(e){
      appLog("Error socketCalling: $e");
    }
  }
  //! Socket Event Handler - Real-time notification updates
  void _handleNotification(dynamic data) {
    appLog("Notification received: $data");
    try {
      if (data != null) {
        // Parse the incoming notification data
        final newNotification = Datum.fromJson(data);
        
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
          "New Project Created", 
          "A new project has been created"
        );
        if (projectNotification != null) {
          _addNewNotificationOptimized(projectNotification);
        }
      }
    } catch (e) {
      appLog("Error handling new project: $e");
    }
  }

  //! Socket Event Handler - Project update notifications
  void _handleUpdateProject(dynamic data) {
    appLog("Update Project received: $data");
    try {
      if (data != null) {
        final projectNotification = _createProjectNotification(
          data, 
          "Project Updated", 
          "A project has been updated"
        );
        if (projectNotification != null) {
          _addNewNotificationOptimized(projectNotification);
        }
      }
    } catch (e) {
      appLog("Error handling project update: $e");
    }
  }

  //! Socket Event Handler - Project deletion notifications
  void _handleDeleteProject(dynamic data) {
    appLog("Delete Project received: $data");
    try {
      if (data != null) {
        final projectNotification = _createProjectNotification(
          data, 
          "Project Deleted", 
          "A project has been deleted"
        );
        if (projectNotification != null) {
          _addNewNotificationOptimized(projectNotification);
        }
      }
    } catch (e) {
      appLog("Error handling project deletion: $e");
    }
  }

  //! Socket Event Handler - Note deletion notifications
  void _handleDeleteNote(dynamic data) {
    appLog("Delete Note received: $data");
    try {
      if (data != null) {
        final noteNotification = _createNoteNotification(
          data, 
          "Note Deleted", 
          "A note has been deleted"
        );
        if (noteNotification != null) {
          _addNewNotificationOptimized(noteNotification);
        }
      }
    } catch (e) {
      appLog("Error handling note deletion: $e");
    }
  }

  // Fetch initial notifications
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        notifications.clear();
      }

      isLoading.value = true;
      hasError.value = false;

      final response = await _notificationRepository.fetchAlltheNotificaton(
        page: currentPage.value,
      );

      if (response.success == true && response.data != null) {
        final newNotifications = response.data!.data ?? [];

        if (isRefresh) {
          notifications.assignAll(newNotifications);
        } else {
          notifications.addAll(newNotifications);
        }
        // Update pagination info
        if (response.data!.meta != null) {
          totalPages.value = response.data!.meta!.totalPages ?? 1;
          hasMoreData.value = currentPage.value < totalPages.value;
          unreadCount.value = response.data!.meta!.unreadCount ?? unreadCount.value;
        }
        appLog(
          "Notifications loaded successfully: ${notifications.length} items",
        );
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? 'Failed to load notifications';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An error occurred while loading notifications';
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
      // Was previously called with no page argument at all — every "load
      // more" silently refetched page 1 instead of advancing, a
      // pre-existing bug caught while wiring real pagination through here.
      final response = await _notificationRepository.fetchAlltheNotificaton(
        page: currentPage.value,
      );

      if (response.success == true && response.data != null) {
        final newNotifications = response.data!.data ?? [];
        notifications.addAll(newNotifications);
        hasMoreData.value = currentPage.value < totalPages.value;
        if (response.data!.meta != null) {
          unreadCount.value = response.data!.meta!.unreadCount ?? unreadCount.value;
        }
      }
    } catch (e) {
      currentPage.value--; // Rollback page increment on error
      appLog("Error loading more notifications: $e");
    }
  }

  /// Marks one notification read: optimistic local update always applied
  /// first (instant UI feedback), then persisted to the backend. If the
  /// device is offline (or the call otherwise fails), the action is queued
  /// via StorageServices and replayed by _syncPendingOfflineActions once
  /// connectivity returns — the local state isn't rolled back, since the
  /// user's intent ("I read this") is still valid and shouldn't silently
  /// disappear just because the network request failed.
  Future<void> markAsRead(String? id) async {
    if (id == null) return;
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (notifications[index].isRead == true) return; // already read, nothing to do

    notifications[index].isRead = true;
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;

    bool isOnline = true;
    try {
      isOnline = Get.find<ConnectivityService>().isConnected;
    } catch (e) {
      appLog("Error checking connectivity in markAsRead: $e");
    }

    if (!isOnline) {
      await storageServices.addPendingMarkReadId(id);
      AppSnackBar.customMessage(AppString.markedReadWillSyncOffline.tr);
      return;
    }

    final success = await _notificationRepository.markNotificationRead(id);
    if (!success) {
      await storageServices.addPendingMarkReadId(id);
    }
  }

  /// Same optimistic-then-persist-then-queue-on-failure shape as
  /// [markAsRead], for all notifications at once.
  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;

    bool isOnline = true;
    try {
      isOnline = Get.find<ConnectivityService>().isConnected;
    } catch (e) {
      appLog("Error checking connectivity in markAllAsRead: $e");
    }

    if (!isOnline) {
      await storageServices.setPendingMarkAllRead(true);
      AppSnackBar.customMessage(AppString.markedReadWillSyncOffline.tr);
      return;
    }

    final success = await _notificationRepository.markAllNotificationsRead();
    if (!success) {
      await storageServices.setPendingMarkAllRead(true);
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications(isRefresh: true);
  }

  // Format notification time
  String formatNotificationTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
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
        if (newNotification.isRead != true) unreadCount.value++;

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

  /// Creates a note notification from socket data
  Datum? _createNoteNotification(dynamic data, String title, String body) {
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
      appLog("Error creating note notification: $e");
      return null;
    }
  }

  /// Shows a visual indicator for new notifications (optional)
  void _showNewNotificationIndicator(Datum notification) {
    try {
      // Shared with PushNotificationService's foreground FCM handler — the
      // backend fires both a socket event and a push for the same event,
      // so whichever arrives first here claims it and the other is
      // suppressed, instead of showing two banners for one notification.
      if (!PushNotificationService.claimForDisplay(notification.id)) {
        appLog("Socket notification indicator suppressed — already shown via push: ${notification.id}");
        return;
      }
      if (Get.isSnackbarOpen == false) {
        Get.snackbar(
          notification.title ?? 'New Notification',
          notification.body ?? 'You have a new notification',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.withValues(alpha: 0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      }
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
       var userId = storageServices.getUserId();
       if (userId.isNotEmpty) {
         // Remove all socket event listeners for this user
         socketAllOperation.appRootSocket?.off("notification::$userId");
         socketAllOperation.appRootSocket?.off("newProject::$userId");
         socketAllOperation.appRootSocket?.off("updateProject::$userId");
         socketAllOperation.appRootSocket?.off("removeProject::$userId");
         socketAllOperation.appRootSocket?.off("note::$userId");
         
         appLog("Socket listeners cleaned up for user: $userId");
       }
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
         socketCalling();
       });
     } catch (e) {
       appLog("Error reconnecting socket: $e");
     }
   }

   /// Check socket connection status
   bool get isSocketConnected => socketAllOperation.isConnected;
}
