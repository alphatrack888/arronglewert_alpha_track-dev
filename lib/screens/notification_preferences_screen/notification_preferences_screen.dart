import 'package:alpha_track/screens/notification_preferences_screen/controller/notification_preferences_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationPreferencesController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: AppColors.primary,
                size: 50,
              ),
            );
          }

          final prefs = controller.preferences.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsAuthHeader(title: AppString.notificationPreferences.tr),
                if (controller.demoMode.value) ...[
                  const SizedBox(height: 12),
                  Text(
                    AppString.preferencesNotAvailableInDemo.tr,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 24),
                DsCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.pushNotifications.tr,
                              style: AppTextStyles.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppString.pushNotificationsHint.tr,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: prefs.pushEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: controller.setPushEnabled,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppString.categories.tr,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                DsCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _categoryToggle(
                        AppString.categoryLeave.tr,
                        prefs.categories.leave,
                        (v) => controller.setCategory('leave', v),
                      ),
                      _categoryToggle(
                        AppString.categoryProject.tr,
                        prefs.categories.project,
                        (v) => controller.setCategory('project', v),
                      ),
                      _categoryToggle(
                        AppString.categoryPayroll.tr,
                        prefs.categories.payroll,
                        (v) => controller.setCategory('payroll', v),
                      ),
                      _categoryToggle(
                        AppString.categoryOvertime.tr,
                        prefs.categories.overtime,
                        (v) => controller.setCategory('overtime', v),
                      ),
                      _categoryToggle(
                        AppString.categoryAttendance.tr,
                        prefs.categories.attendance,
                        (v) => controller.setCategory('attendance', v),
                      ),
                      _categoryToggle(
                        AppString.categorySubscription.tr,
                        prefs.categories.subscription,
                        (v) => controller.setCategory('subscription', v),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppString.delivery.tr,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                DsCard(
                  child: _styledDropdown<String>(
                    value: prefs.digestMode,
                    items: [
                      DropdownMenuItem(
                        value: 'realtime',
                        child: Text(AppString.deliveryRealtime.tr),
                      ),
                      DropdownMenuItem(
                        value: 'daily',
                        child: Text(AppString.deliveryDaily.tr),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setDigestMode(value);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppString.languageLabel.tr,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                DsCard(
                  child: _styledDropdown<String>(
                    value: prefs.language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setLanguage(value);
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Obx(
                  () => PrimaryButton(
                    label: AppString.saveChanges.tr,
                    isLoading: controller.isSaving.value,
                    onTap: () => controller.savePreferences(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey('dropdown-$value'),
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _categoryToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: AppTextStyles.bodyMedium),
              ),
              Switch(
                value: value,
                activeThumbColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.stroke),
          ),
      ],
    );
  }
}
