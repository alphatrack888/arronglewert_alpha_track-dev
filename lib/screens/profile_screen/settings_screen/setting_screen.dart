import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get/get.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsAuthHeader(title: AppString.settings.tr),
              const SizedBox(height: 24),
              DsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _settingsRow(
                      svgIcon: AppIcons.changePassword,
                      label: AppString.changePasswod.tr,
                      onTap: () =>
                          Get.toNamed(AppRoute.changePasswordScreen),
                    ),
                    _divider(),
                    _settingsRow(
                      svgIcon: AppIcons.notificationIcons,
                      label: AppString.notificationPreferences.tr,
                      onTap: () =>
                          Get.toNamed(AppRoute.notificationPreferencesScreen),
                    ),
                    _divider(),
                    _settingsRow(
                      svgIcon: AppIcons.privacyPolicy,
                      label: AppString.privacyPolicy.tr,
                      onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
                    ),
                    _divider(),
                    _settingsRow(
                      svgIcon: AppIcons.deleteAccount,
                      label: AppString.deleteAccount.tr,
                      iconColor: AppColors.danger,
                      iconBackground: AppColors.danger.withValues(alpha: 0.1),
                      onTap: () async {
                        final confirmed = await DsDialog.confirm(
                          title: AppString.deleteAccount.tr,
                          message: AppString.areyouSuretoDeleteAccount.tr,
                          confirmLabel: AppString.deleteAccount.tr,
                          cancelLabel: AppString.cancel.tr,
                          icon: LucideIcons.trash2,
                        );
                        if (confirmed) {
                          // TODO: wire account deletion to the backend.
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1, color: AppColors.stroke),
    );
  }

  Widget _settingsRow({
    required String svgIcon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = AppColors.primary,
    Color iconBackground = AppColors.primarySoft,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                svgIcon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTextStyles.bodySemibold),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.textFaint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

