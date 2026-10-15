import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/notification_screen/controller/notification_screen_controller.dart';
import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:alpha_track/utils/i18n/server_text.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationScreenController controller =
      Get.find<NotificationScreenController>();

  // Local UI state for "Manage" multi-select mode (presentation only).
  bool _manageMode = false;
  final Set<String> _selectedIds = <String>{};

  void _enterManageMode() {
    setState(() {
      _manageMode = true;
      _selectedIds.clear();
    });
  }

  void _exitManageMode() {
    setState(() {
      _manageMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String? id) {
    if (id == null) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _markSelectedAsRead(Iterable<Datum> items) async {
    for (final n in items) {
      if (n.isRead != true) {
        await controller.markAsRead(n.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                color: AppColors.primary,
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.notifications.isEmpty) {
                    return Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: AppColors.primary,
                        size: 50,
                      ),
                    );
                  }

                  if (controller.hasError.value &&
                      controller.notifications.isEmpty) {
                    return _buildErrorState();
                  }

                  if (controller.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: _manageMode ? 120 : 16,
                    ),
                    itemCount:
                        controller.notifications.length +
                        (controller.hasMoreData.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final notification = controller.notifications[index];
                      return _buildNotificationRow(notification);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  void _showNotificationMenu() {
    DsBottomSheet.show(
      DsBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsSheetAction(
              icon: LucideIcons.listChecks,
              label: AppString.notificationManage.tr,
              onTap: () {
                Get.back();
                _enterManageMode();
              },
            ),
            DsSheetAction(
              icon: LucideIcons.settings,
              label: AppString.notificationPreferences.tr,
              showChevron: true,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoute.notificationPreferencesScreen);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          if (!_manageMode) const DsBackButton(),
          if (!_manageMode) const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppString.notifications.tr,
              style: AppTextStyles.headline,
            ),
          ),
          if (_manageMode)
            GestureDetector(
              onTap: _exitManageMode,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
            )
          else
            DsCircleIconButton(
              icon: LucideIcons.ellipsis,
              onTap: _showNotificationMenu,
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notification row
  // ---------------------------------------------------------------------------
  Widget _buildNotificationRow(Datum notification) {
    final id = notification.id;
    final isSelected = id != null && _selectedIds.contains(id);
    final isUnread = notification.isRead != true;

    final row = Container(
      color: isSelected ? AppColors.surface : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_manageMode) ...[
            _SelectionBox(selected: isSelected),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizeServerText(notification.title) ?? AppString.notification.tr,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread && !_manageMode) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (notification.body != null &&
                    notification.body!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    localizeServerText(notification.body)!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (notification.from?.name != null ||
                    notification.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (notification.from?.name != null)
                        Expanded(
                          child: Text(
                            '${AppString.from.tr}: ${_getEnumValue(notification.from!.name)}',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      Text(
                        controller.formatNotificationTime(
                          notification.createdAt,
                        ),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    final tappableRow = InkWell(
      onTap: _manageMode ? () => _toggleSelection(id) : null,
      onLongPress: _manageMode
          ? null
          : () => _showNotificationDetails(notification),
      child: row,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Swipe left on a single notification to delete it. Disabled while the
        // multi-select "Manage" mode is active, and only when the row has an id
        // the controller can remove by.
        if (_manageMode || id == null)
          tappableRow
        else
          Dismissible(
            key: ValueKey('notif_$id'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              controller.deleteNotification(id);
            },
            background: Container(
              color: AppColors.danger.withValues(alpha: 0.12),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.trash2,
                      size: 20, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: AppTextStyles.bodySemibold
                        .copyWith(color: AppColors.danger),
                  ),
                ],
              ),
            ),
            child: tappableRow,
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.stroke),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom action bar (manage mode)
  // ---------------------------------------------------------------------------
  Widget? _buildBottomActionBar() {
    if (!_manageMode) return null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'markAsRead'.tr,
                isTranslate: false,
                onTap: () async {
                  final selected = controller.notifications
                      .where((n) => n.id != null && _selectedIds.contains(n.id))
                      .toList();
                  await _markSelectedAsRead(selected);
                  _exitManageMode();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                label: 'markAllAsRead'.tr,
                isTranslate: false,
                onTap: () async {
                  await controller.markAllAsRead();
                  _exitManageMode();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty / error states
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(
          LucideIcons.bellOff,
          size: 64,
          color: AppColors.textFaint,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            AppString.noNotificationsYet.tr,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppString.notificationsHint.tr,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(LucideIcons.circleAlert, size: 64, color: AppColors.textFaint),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 160,
            child: PrimaryButton(
              label: AppString.retry.tr,
              isTranslate: false,
              onTap: () => controller.fetchNotifications(isRefresh: true),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers (logic preserved from original)
  // ---------------------------------------------------------------------------
  String _getEnumValue(dynamic enumValue) {
    if (enumValue is String) {
      return enumValue;
    }
    return enumValue.toString().split('.').last.replaceAll('_', ' ');
  }

  /// Show notification details on long press.
  void _showNotificationDetails(Datum notification) {
    if (notification.isRead != true) {
      controller.markAsRead(notification.id);
    }
    DsBottomSheet.show(
      DsBottomSheet(
        title: AppString.notificationDetails.tr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title != null && notification.title!.isNotEmpty)
              _detailBlock(AppString.titleLabel.tr, notification.title!),
            if (notification.body != null && notification.body!.isNotEmpty)
              _detailBlock(AppString.messageLabel.tr, notification.body!),
            if (notification.from?.name != null)
              _detailBlock(
                AppString.from.tr,
                _getEnumValue(notification.from!.name),
              ),
            if (notification.createdAt != null)
              _detailBlock(
                AppString.received.tr,
                _formatFullDateTime(notification.createdAt!),
              ),
            PrimaryButton(
              label: AppString.close.tr,
              isTranslate: false,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySemibold.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body),
        const SizedBox(height: 12),
      ],
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

/// Square selection checkbox shown in manage mode.
class _SelectionBox extends StatelessWidget {
  const _SelectionBox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textFaint,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(LucideIcons.check, size: 16, color: AppColors.white50)
          : null,
    );
  }
}
