import 'package:alpha_track/screens/notification_preferences_screen/controller/notification_preferences_controller.dart';
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

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationPreferencesController());

    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.notificationPreferences.tr,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: AppColors.blue500,
              size: 50,
            ),
          );
        }

        final prefs = controller.preferences.value;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSize.width(value: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: AppString.pushNotifications.tr,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black500,
                          ),
                          Gap(height: AppSize.height(value: 4)),
                          AppText(
                            text: AppString.pushNotificationsHint.tr,
                            fontSize: 12,
                            color: Colors.grey[600],
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: prefs.pushEnabled,
                      activeThumbColor: AppColors.blue500,
                      onChanged: controller.setPushEnabled,
                    ),
                  ],
                ),
              ),
              Gap(height: AppSize.height(value: 16)),

              AppText(
                text: AppString.categories.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
              ),
              Gap(height: AppSize.height(value: 8)),
              _sectionCard(
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
              Gap(height: AppSize.height(value: 16)),

              AppText(
                text: AppString.delivery.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
              ),
              Gap(height: AppSize.height(value: 8)),
              _sectionCard(
                child: DropdownButtonFormField<String>(
                  initialValue: prefs.digestMode,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.black400),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'realtime', child: Text(AppString.deliveryRealtime.tr)),
                    DropdownMenuItem(value: 'daily', child: Text(AppString.deliveryDaily.tr)),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setDigestMode(value);
                  },
                ),
              ),
              Gap(height: AppSize.height(value: 16)),

              AppText(
                text: AppString.languageLabel.tr,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
              ),
              Gap(height: AppSize.height(value: 8)),
              _sectionCard(
                child: DropdownButtonFormField<String>(
                  initialValue: prefs.language,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.black400),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setLanguage(value);
                  },
                ),
              ),
              Gap(height: AppSize.height(value: 28)),

              Obx(
                () => AppButton(
                  height: AppSize.height(value: 48),
                  title: controller.isSaving.value ? '...' : AppString.saveChanges.tr,
                  titleColor: AppColors.white100,
                  backgroundColor: AppColors.blue500,
                  onTap: controller.isSaving.value
                      ? () {}
                      : () async {
                          await controller.savePreferences();
                        },
                ),
              ),
              Gap(height: AppSize.height(value: 20)),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: child,
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
        Row(
          children: [
            Expanded(
              child: AppText(text: label, fontSize: 14, color: AppColors.black500),
            ),
            Switch(value: value, activeThumbColor: AppColors.blue500, onChanged: onChanged),
          ],
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
      ],
    );
  }
}
