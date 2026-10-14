import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/auth_screen/signup_screen/controller/signup_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_password_criteria.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  final SignupScreenController controller = Get.find<SignupScreenController>();

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
                title: 'createAccount'.tr,
                subtitle:
                    'signupSub'.tr,
              ),
              const SizedBox(height: 32),
              //! Name Field
              Text(AppString.fullName.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: AppString.enterYourFullName.tr,
                height: 52,
                controller: controller.name,
                prefixIcon: LucideIcons.user,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              //! Email Field
              Text('Email', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterYourEmail'.tr,
                height: 52,
                controller: controller.email,
                prefixIcon: LucideIcons.mail,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              //! Contact Number
              Text(AppString.contactNumber.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: AppString.enterYourContactNumber.tr,
                height: 52,
                controller: controller.contactNumber,
                prefixIcon: LucideIcons.phone,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              //! Designation Field
              Text(AppString.designation.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: AppString.enterYourDesignation.tr,
                height: 52,
                controller: controller.designation,
                prefixIcon: LucideIcons.idCard,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              //! Password Field
              Text('password'.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterPassword'.tr,
                height: 52,
                isPassword: true,
                controller: controller.password,
                prefixIcon: LucideIcons.lock,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 20),
              //! Confirm Password Field
              Text('confirmPassword'.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterPassword'.tr,
                isPassword: true,
                height: 52,
                controller: controller.confirmPassword,
                prefixIcon: LucideIcons.lock,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              //! Password rules checklist (live, reacts to Password)
              DsPasswordCriteria(controller: controller.password),
              const SizedBox(height: 28),
              //! Sign Up Button
              Obx(
                () => PrimaryButton(
                  label: 'createAccount'.tr,
                  isTranslate: false,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.register(),
                ),
              ),
              //! Already have an account
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.alreadyhaveAnAccount.tr,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoute.loginScreen);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Text(
                      AppString.login.tr,
                      style: AppTextStyles.bodySemibold
                          .copyWith(color: AppColors.primary),
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
}
