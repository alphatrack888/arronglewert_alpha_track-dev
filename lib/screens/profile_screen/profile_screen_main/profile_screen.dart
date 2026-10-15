import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/socket_service/socket_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_images/app_images.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:alpha_track/widgets/ds/ds_menu_item.dart';
import 'package:alpha_track/widgets/ds/ds_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  void _editProfile() {
    Get.toNamed(AppRoute.personalInformationScreen);
    profileController.onTap();
  }

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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('account'.tr, style: AppTextStyles.headline),
              ),
              const SizedBox(height: 12),
              _buildProfileCard(),
              const SizedBox(height: 24),

              // WORK
              DsSectionHeader(title: 'secWork'.tr, isTranslate: false),
              const SizedBox(height: 12),
              DsMenuItem(
                icon: LucideIcons.image,
                label: AppString.gallery.tr,
                onTap: () => Get.toNamed(AppRoute.galleryScreen),
              ),
              DsMenuItem(
                icon: LucideIcons.fileText,
                label: AppString.payRole.tr,
                onTap: () => Get.toNamed(AppRoute.payRoleScreen),
              ),
              DsMenuItem(
                icon: LucideIcons.coffee,
                label: 'breakSettings'.tr,
                onTap: () => Get.toNamed(AppRoute.breakScreen),
              ),
              DsMenuItem(
                icon: LucideIcons.palmtree,
                label: 'leaveSchedule'.tr,
                onTap: () => Get.toNamed(AppRoute.leaveScheduleScreen),
              ),
              const SizedBox(height: 12),

              // SECURITY & PRIVACY
              DsSectionHeader(
                  title: 'secSecurityPrivacy'.tr, isTranslate: false),
              const SizedBox(height: 12),
              DsMenuItem(
                icon: LucideIcons.lock,
                label: 'password'.tr,
                onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
              ),
              DsMenuItem(
                icon: LucideIcons.slidersHorizontal,
                label: 'preferences'.tr,
                onTap: () => Get.toNamed(AppRoute.languageScreen),
              ),
              const SizedBox(height: 12),

              // APP
              DsSectionHeader(title: 'secApp'.tr, isTranslate: false),
              const SizedBox(height: 12),
              DsMenuItem(
                icon: LucideIcons.info,
                label: 'contact'.tr,
                badge: 'soon'.tr,
                onTap: () => AppSnackBar.message('contactComingSoon'.tr),
              ),
              DsMenuItem(
                icon: LucideIcons.helpCircle,
                label: 'help'.tr,
                badge: 'soon'.tr,
                onTap: () => AppSnackBar.message('helpComingSoon'.tr),
              ),
              DsMenuItem(
                icon: LucideIcons.shield,
                label: 'privacyPolicy'.tr,
                onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
              ),
              const SizedBox(height: 20),

              // Log Out — red outline pill (centered)
              Center(child: _logoutButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return DsCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AppImage(
                    url: profileController.profileData.value?.data?.profile,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                  if (profileController.isLoading.value)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.black500.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: LoadingAnimationWidget.beat(
                            size: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileController.fullName.isEmpty
                        ? 'yourName'.tr
                        : profileController.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  if (profileController.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _metaLine(LucideIcons.mail, profileController.email),
                  ],
                  if (profileController.phone.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    _metaLine(LucideIcons.phone, profileController.phone),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _editProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                'editProfile'.tr,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.subtitle),
        ),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await DsDialog.confirm(
      title: AppString.areyouSureYouWantToLogOut.tr,
      message: AppString.logout.tr,
      confirmLabel: AppString.yes.tr,
      cancelLabel: AppString.no.tr,
      icon: LucideIcons.logOut,
    );
    if (!confirmed) return;
    try {
      await PushNotificationService.instance.deregisterCurrentToken();
      AppSocketAllOperation.instance.disconnectAndClear();
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().profileData.value = null;
      }
      await StorageServices.instance.storageClear();
      Get.offAllNamed(AppRoute.splashScreen);
      AppSnackBar.success('loggedOut'.tr);
    } catch (e) {
      errorLog("Logout Error", e);
      AppSnackBar.error('logoutFailed'.tr);
    }
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.danger),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.logOut, size: 18, color: AppColors.danger),
            const SizedBox(width: 8),
            Text(
              AppString.logout.tr,
              style: AppTextStyles.button.copyWith(color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

}
