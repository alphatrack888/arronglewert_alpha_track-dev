import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/break_screen/break_screen/controller/break_settings_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Break Settings — automatic break reminders (hourly in-app prompt when enabled).
class BreakScreen extends StatelessWidget {
  const BreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BreakSettingsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const DsBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('breakSettings'.tr, style: AppTextStyles.title),
                  ),
                  _circleBtn(LucideIcons.history,
                      () => Get.toNamed(AppRoute.breakHistoryScreen)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _toggleRow(
                title: 'automaticBreak'.tr,
                subtitle: 'automaticBreakSub'.tr,
                value: controller.automaticBreakEnabled.value,
                onChanged: (v) => controller.setAutomaticBreak(v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration:
            const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _toggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.subtitle.copyWith(height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white50,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
