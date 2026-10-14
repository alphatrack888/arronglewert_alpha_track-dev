import 'dart:ui';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/auth_screen/reset_password_screen/controller/reset_password_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_password_criteria.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});
  final controller = Get.find<ResetPasswordScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsAuthHeader(
                title: 'resetPassword'.tr,
                subtitle:
                    'resetSub'.tr,
              ),
              const SizedBox(height: 32),
              //! Email (disabled / prefilled)
              Text('Email', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Container(
                height: 52,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.mail,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'marcg@gmail.com',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.stroke, height: 1),
              const SizedBox(height: 16),
              //! New Password Field
              Text('newPassword'.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterPassword'.tr,
                height: 52,
                controller: controller.newPassword,
                isPassword: true,
                prefixIcon: LucideIcons.lock,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
              ),
              const SizedBox(height: 20),
              //! Confirm Password Field
              Text('confirmPassword'.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterPassword'.tr,
                height: 52,
                controller: controller.confirmPassword,
                isPassword: true,
                prefixIcon: LucideIcons.lock,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              //! Password rules checklist (live, reacts to New Password)
              DsPasswordCriteria(controller: controller.newPassword),
              const SizedBox(height: 28),
              //! Confirm Button
              Obx(
                () => PrimaryButton(
                  label: 'saveNewPassword'.tr,
                  isTranslate: false,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.resetPassword(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget passwordChangeDialog(BuildContext context) {
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
            Center(
              child: Image.asset(
                AppImages.resetPasswordSuccess,
                height: AppSize.height(
                  value: 80,
                ), // Adjust size to match the image
                width: AppSize.width(value: 80),
              ),
            ),
            Gap(height: AppSize.height(value: 20)),
            AppText(
              text: AppString.successfully.tr,
              fontSize: AppSize.width(value: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Gap(height: AppSize.height(value: 20)),
            AppButton(
              title: AppString.backToLogin.tr,
              height: AppSize.height(value: 48),
              backgroundColor: AppColors.blue500,
              borderColor: Colors.transparent,
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoute.loginScreen);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
