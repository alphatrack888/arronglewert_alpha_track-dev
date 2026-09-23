import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/services/repository/notification_repository/notification_repository.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
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

  // Controllers
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _setupScrollListener();
    socketCalling();
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

      final response = await _notificationRepository.fetchAlltheNotificaton();

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
      final response = await _notificationRepository.fetchAlltheNotificaton();

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
      // You can implement a snackbar, toast, or other UI indicator here
      // For example, using GetX snackbar:
      if (Get.isSnackbarOpen == false) {
        Get.snackbar(
          notification.title ?? 'New Notification',
          notification.body ?? 'You have a new notification',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.withOpacity(0.8),
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
