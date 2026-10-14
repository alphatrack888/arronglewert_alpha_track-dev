import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/auth_screen/login_screen/controller/login_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final controller = Get.find<LoginScreenController>();

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
                title: AppString.login.tr,
                subtitle:
                    'loginSub'.tr,
              ),
              const SizedBox(height: 32),
              //! Email Field
              Text('Email', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterYourEmail'.tr,
                height: 52,
                controller: controller.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: LucideIcons.mail,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
              ),
              const SizedBox(height: 20),
              //! Password Field
              Text('password'.tr, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'enterPassword'.tr,
                height: 52,
                controller: controller.password,
                isPassword: true,
                prefixIcon: LucideIcons.lock,
                backgroundColor: AppColors.surface,
                borderColor: AppColors.stroke,
                borderRadius: 12,
                hintTextColor: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              //! Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Get.toNamed(AppRoute.forgotPasswordScreen);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Text(
                    'forgotPasswordQ'.tr,
                    style: AppTextStyles.bodySemibold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              //! Remember Me
              Row(
                children: [
                  Obx(
                    () => SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.isCheked.value,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          controller.isCheked.value = value!;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppString.rememberMe.tr,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              //! Login Button
              Obx(
                () => PrimaryButton(
                  label: 'signIn'.tr,
                  isTranslate: false,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.loginEmployee(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
