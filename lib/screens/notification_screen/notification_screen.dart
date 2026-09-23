import 'package:alpha_track/screens/notification_screen/controller/notification_screen_controller.dart';
import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationScreenController>();

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.notifications.tr,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: AppColors.blue500,
                size: 50,
              ),
            );
          }

          if (controller.hasError.value && controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  Gap(height: AppSize.height(value: 16)),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Gap(height: AppSize.height(value: 16)),
                  ElevatedButton(
                    onPressed: controller.fetchNotifications,
                    child: Text(AppString.retry.tr),
                  ),
                ],
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  Gap(height: AppSize.height(value: 16)),
                  Text(
                    AppString.noNotificationsYet.tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(height: AppSize.height(value: 8)),
                  Text(
                    AppString.notificationsHint.tr,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 16)),
            itemCount:
                controller.notifications.length +
                (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.notifications.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: LoadingAnimationWidget.beat(
                      size: 24,
                      color: AppColors.blue500,
                    ),
                  ),
                );
              }

              final notification = controller.notifications[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildNotificationCard(notification, controller, index),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(
    Datum notification,
    NotificationScreenController controller,
    int index,
  ) {
    final isNewNotification =
        index == 0 &&
        notification.createdAt != null &&
        DateTime.now().difference(notification.createdAt!).inSeconds < 10;

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.height(value: 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNewNotification
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.2),
          width: isNewNotification ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isNewNotification
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isNewNotification ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onLongPress: () {
          _showNotificationDetails(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSize.width(value: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New notification indicator
              if (isNewNotification)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppString.newLabel.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon with pulse animation for new notifications
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNotificationIconColor(notification.title),
                      shape: BoxShape.circle,
                      boxShadow: isNewNotification
                          ? [
                              BoxShadow(
                                color: _getNotificationIconColor(
                                  notification.title,
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.title),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Gap(width: AppSize.width(value: 12)),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title ?? AppString.notification.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (notification.body != null &&
                            notification.body!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              top: AppSize.height(value: 4),
                            ),
                            child: Text(
                              notification.body!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Sender and Time Info
                        Padding(
                          padding: EdgeInsets.only(
                            top: AppSize.height(value: 8),
                          ),
                          child: Row(
                            children: [
                              if (notification.from?.name != null)
                                Expanded(
                                  child: Text(
                                    '${AppString.from.tr}: ${_getEnumValue(notification.from!.name)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              Text(
                                controller.formatNotificationTime(
                                  notification.createdAt,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? title) {
    if (title == null) return Icons.notifications;

    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('message') || lowerTitle.contains('chat')) {
      return Icons.chat_bubble;
    } else if (lowerTitle.contains('update') || lowerTitle.contains('news')) {
      return Icons.update;
    } else if (lowerTitle.contains('warning') || lowerTitle.contains('alert')) {
      return Icons.warning;
    } else if (lowerTitle.contains('success') ||
        lowerTitle.contains('completed')) {
      return Icons.check_circle;
    } else if (lowerTitle.contains('reminder')) {
      return Icons.access_time;
    } else {
      return Icons.notifications;
    }
  }

  Color _getNotificationIconColor(String? title) {
    if (title == null) return Colors.blue;

    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('message') || lowerTitle.contains('chat')) {
      return Colors.green;
    } else if (lowerTitle.contains('update') || lowerTitle.contains('news')) {
      return Colors.blue;
    } else if (lowerTitle.contains('warning') || lowerTitle.contains('alert')) {
      return Colors.orange;
    } else if (lowerTitle.contains('success') ||
        lowerTitle.contains('completed')) {
      return Colors.teal;
    } else if (lowerTitle.contains('reminder')) {
      return Colors.purple;
    } else {
      return Colors.blue;
    }
  }

  String _getEnumValue(dynamic enumValue) {
    if (enumValue is String) {
      return enumValue;
    }
    return enumValue.toString().split('.').last.replaceAll('_', ' ');
  }

  /// Show notification details on long press
  void _showNotificationDetails(Datum notification) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(height: 15),

            // Title
            AppText(
              text: AppString.notificationDetails.tr,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const Gap(height: 14),

            // Notification Title
            if (notification.title != null && notification.title!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppString.titleLabel.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  const Gap(height: 4),
                  AppText(
                    text: notification.title!,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  const Gap(height: 10),
                ],
              ),

            // Notification Body
            if (notification.body != null && notification.body!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppString.messageLabel.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  const Gap(height: 4),
                  AppText(
                    text: notification.body!,
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(height: 10),
                ],
              ),

            // From Information
            if (notification.from?.name != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppString.from.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  const Gap(height: 4),
                  AppText(
                    text: _getEnumValue(notification.from!.name),
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  const Gap(height: 10),
                ],
              ),

            // Created At
            if (notification.createdAt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppString.received.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  const Gap(height: 4),
                  AppText(
                    text: _formatFullDateTime(notification.createdAt!),
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  const Gap(height: 10),
                ],
              ),

            // Close Button
            AppButton(
              height: AppSize.height(value: 40),
              title: AppString.close.tr,
              titleColor: AppColors.white100,
              backgroundColor: AppColors.blue500,
              onTap: () => Get.back(),
            ),
            const Gap(height: 15),
          ],
        ),
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final time = _formatTime(dateTime);
      return '${AppString.today.tr} ${AppString.at.tr} $time';
    } else if (difference.inDays == 1) {
      final time = _formatTime(dateTime);
      return '${AppString.yesterday.tr} ${AppString.at.tr} $time';
    } else {
      final months = [
        AppString.jan.tr,
        AppString.feb.tr,
        AppString.mar.tr,
        AppString.apr.tr,
        AppString.may.tr,
        AppString.jun.tr,
        AppString.jul.tr,
        AppString.aug.tr,
        AppString.sep.tr,
        AppString.oct.tr,
        AppString.nov.tr,
        AppString.dec.tr,
      ];
      final month = months[dateTime.month - 1];
      final day = dateTime.day;
      final year = dateTime.year;
      final time = _formatTime(dateTime);

      if (year == now.year) {
        return '$month $day ${AppString.at.tr} $time';
      } else {
        return '$month $day, $year ${AppString.at.tr} $time';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = isPm ? AppString.pm.tr : AppString.am.tr;
    return '$displayHour:$minute $period';
  }
}
