import 'package:alpha_track/screens/profile_screen/settings_screen/change_pasword/controller/chanage_password_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  final ChanagePasswordController chanagePasswordController =
      Get.find<ChanagePasswordController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.changePasswod.tr,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(height: AppSize.height(value: 25)),
            //! Old Password
            AppText(
              text: AppString.oldPassword.tr,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourPassword.tr,
              height: AppSize.height(value: 48),
              isPassword: true,
              controller: chanagePasswordController.oldPasswordController,
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.visiblePassword,
            ),
            Gap(height: AppSize.height(value: 15)),
            //! New Password
            AppText(
              text: AppString.newPassword.tr,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourPassword.tr,
              height: AppSize.height(value: 48),
              controller: chanagePasswordController.newPasswordController,
              isPassword: true,
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.visiblePassword,
            ),
            Gap(height: AppSize.height(value: 15)),
            //! Confirm Password
            AppText(
              text: AppString.confirmPassword.tr,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourPassword.tr,
              height: AppSize.height(value: 48),
              controller: chanagePasswordController.confirmPasswordController,
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              isPassword: true,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.visiblePassword,
            ),
            Gap(height: AppSize.height(value: 15)),
            //! Save Button
            Obx(
              () => AppButton(
                title: AppString.saveChanges.tr,
                height: AppSize.height(value: 48),
                width: double.infinity,
                borderradius: 6,
                fontSize: 16,
                backgroundColor: AppColors.blue500,
                titleColor: AppColors.white200,
                isLoading: chanagePasswordController.isLoading.value,
                onTap: () {
                  chanagePasswordController.changePassword();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
