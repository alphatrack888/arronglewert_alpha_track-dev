import 'package:alpha_track/screens/auth_screen/forgot_password_screen/controller/forgot_password_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final ForgotPasswordController controller =
      Get.find<ForgotPasswordController>();

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
                    'forgotSub'.tr,
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
              const SizedBox(height: 24),
              //! Reset Button
              Obx(
                () => PrimaryButton(
                  label: 'resetPassword'.tr,
                  isTranslate: false,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.sendForgotPasswordRequest(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
