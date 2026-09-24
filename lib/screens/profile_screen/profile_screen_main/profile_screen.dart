import 'dart:ui';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_button/app_icon_button.dart';
import 'package:alpha_track/widgets/app_images/app_images.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.profiles.tr,
        showAction: false,
        showLeading: false,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          children: [
            // Replace this section in your ProfileScreen build method:
            Gap(height: AppSize.height(value: 35)),
            Obx(
              () => Container(
                width: AppSize.width(value: 140),
                height: AppSize.width(value: 140),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black500.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Profile Image
                      Obx(
                        () => AppImage(
                          url: profileController
                              .profileData
                              .value
                              ?.data
                              ?.profile,
                          width: AppSize.width(value: 140),
                          height: AppSize.width(value: 140),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Loading Indicator (shows when loading)
                      if (profileController.isLoading.value)
                        Container(
                          width: AppSize.width(value: 120),
                          height: AppSize.width(value: 120),
                          decoration: BoxDecoration(
                            color: AppColors.black500.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Center(
                            child: LoadingAnimationWidget.beat(
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Gap(height: AppSize.height(value: 15)),
            Obx(
              () => Center(
                child: AppText(
                  text: profileController.fullName,
                  fontSize: AppSize.width(value: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black500,
                ),
              ),
            ),
            Gap(height: 16),
            AppButtonWithIcon(
              buttonText: AppString.personalInformation.tr,
              svgIconPath: AppIcons.personalInformation,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.personalInformationScreen);
                profileController.onTap();
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              buttonText: AppString.settings.tr,
              svgIconPath: AppIcons.settingsIcons,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.settingScreen);
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              buttonText: AppString.payRole.tr,
              svgIconPath: AppIcons.payRoleIcons,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.payRoleScreen);
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            // Phase 13: generated timesheet/attendance reports, kept
            // separate from Pay Role (company-uploaded payroll documents
            // are a different concept from self-service generated
            // reports) — see Notification_Reports_Integration_Plan.md
            // Phase 13 for the product decision behind this split.
            AppButtonWithIcon(
              buttonText: AppString.report.tr,
              svgIconPath: AppIcons.pdfIcons,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.reportsScreen);
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              buttonText: AppString.gallery.tr,
              svgIconPath: AppIcons.galleryIcon,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.galleryScreen);
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              buttonText: AppString.languageChanges.tr,
              svgIconPath: AppIcons.languageChanges,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.languageScreen);
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              buttonText: AppString.logout.tr,
              svgIconPath: AppIcons.logoutIcons,
              textColor: AppColors.red,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return logoutDialog(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget logoutDialog(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: AppSize.width(value: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.white100,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(height: AppSize.height(value: 20)),
              AppText(
                text: AppString.areyouSureYouWantToLogOut.tr,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black500,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(height: AppSize.height(value: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AppButton(
                    title: AppString.no.tr,
                    width: AppSize.width(value: 60),
                    height: AppSize.height(value: 48),
                    backgroundColor: AppColors.blue500,
                    borderColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  AppButton(
                    title: AppString.yes.tr,
                    width: AppSize.width(value: 60),
                    height: AppSize.height(value: 48),
                    backgroundColor: AppColors.red,
                    borderColor: Colors.transparent,
                    onTap: () async {
                      try {
                        // Must run before storageClear() below — it needs
                        // the still-present access token to authenticate,
                        // and deregisters this device so a shared/kiosk
                        // device stops receiving push for this user once
                        // logged out.
                        await PushNotificationService.instance
                            .deregisterCurrentToken();
                        // Clear all stored user data
                        await StorageServices.instance.storageClear();
                        // Navigate to the onboarding screen
                        Get.offAllNamed(AppRoute.splashScreen);
                        // Show success message
                        AppSnackBar.success("Logged out successfully.");
                      } catch (e) {
                        // Log the error and show an error message
                        errorLog("Logout Error", e);
                        AppSnackBar.error(
                          "Failed to log out. Please try again.",
                        );
                      }
                    },
                  ),
                ],
              ),
              Gap(height: AppSize.height(value: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
