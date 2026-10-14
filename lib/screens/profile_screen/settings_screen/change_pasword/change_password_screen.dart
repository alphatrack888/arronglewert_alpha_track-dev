import 'package:alpha_track/screens/profile_screen/settings_screen/change_pasword/controller/chanage_password_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_password_criteria.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  final ChanagePasswordController chanagePasswordController =
      Get.find<ChanagePasswordController>();

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
              DsAuthHeader(
                title: AppString.changePasswod.tr,
                subtitle: 'createOrResetPassword'.tr,
              ),
              const SizedBox(height: 24),
              //! Old Password
              _fieldLabel(AppString.oldPassword.tr),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: AppString.enterYourPassword.tr,
                height: 52,
                isPassword: true,
                prefixIcon: LucideIcons.lock,
                controller: chanagePasswordController.oldPasswordController,
                backgroundColor: AppColors.surface,
                borderRadius: 12,
                borderColor: AppColors.stroke,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 18),
              //! New Password
              _fieldLabel(AppString.newPassword.tr),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: AppString.enterYourPassword.tr,
                height: 52,
                controller: chanagePasswordController.newPasswordController,
                isPassword: true,
                prefixIcon: LucideIcons.lock,
                backgroundColor: AppColors.surface,
                borderRadius: 12,
                borderColor: AppColors.stroke,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 18),
              //! Confirm Password
              _fieldLabel(AppString.confirmPassword.tr),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: AppString.enterYourPassword.tr,
                height: 52,
                controller: chanagePasswordController.confirmPasswordController,
                backgroundColor: AppColors.surface,
                borderRadius: 12,
                isPassword: true,
                prefixIcon: LucideIcons.lock,
                borderColor: AppColors.stroke,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 18),
              // Password requirements (live, reacts to New Password)
              DsPasswordCriteria(
                controller: chanagePasswordController.newPasswordController,
              ),
              const SizedBox(height: 24),
              //! Save Button
              Obx(
                () => PrimaryButton(
                  label: 'saveNewPassword'.tr,
                  isTranslate: false,
                  isLoading: chanagePasswordController.isLoading.value,
                  onTap: chanagePasswordController.isLoading.value
                      ? null
                      : () async {
                          final ok = await chanagePasswordController
                              .changePassword();
                          if (ok && context.mounted) dsPop(context);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
    );
  }

}
