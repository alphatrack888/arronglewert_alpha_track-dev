import 'dart:ui';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/auth_screen/reset_password_screen/controller/reset_password_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});
  final controller = Get.find<ResetPasswordScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.createANewPassword.tr,
        showLeading: true,
        showAction: false,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(height: AppSize.height(value: 30)),
            Image.asset(
              AppImages.createNewPassword,
              height: AppSize.height(value: 180),
              width: AppSize.width(value: 180),
            ),
            Gap(height: AppSize.height(value: 54)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.white50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    blurRadius: 5.0,
                    offset: Offset(0, -15),
                  ),
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    offset: Offset(0, -10),
                  ),
                  BoxShadow(color: Colors.white, offset: Offset(0, -10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: AppText(
                      text: AppString.createANewPassword.tr,
                      fontSize: AppSize.width(value: 18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black500,
                    ),
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  Center(
                    child: AppText(
                      text: AppString.pleaseChooseANewPassword.tr,
                      fontSize: AppSize.width(value: 14),
                      fontWeight: FontWeight.w500,
                      maxLines: 4,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.black400,
                    ),
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  //! Password Field
                  AppText(
                    text: AppString.password.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black500,
                  ),
                  Gap(height: AppSize.height(value: 05)),
                  CustomTextField(
                    hintText: AppString.enterYourPassword.tr,
                    height: AppSize.height(value: 48),
                    controller: controller.newPassword,
                    backgroundColor: AppColors.blue50,
                    borderRadius: 6,
                    isPassword: true,
                    borderColor: Colors.transparent,
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  //! Confirm Password Field
                  AppText(
                    text: AppString.confirmPassword.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black500,
                  ),
                  Gap(height: AppSize.height(value: 05)),
                  CustomTextField(
                    hintText: AppString.enterYourPassword.tr,
                    height: AppSize.height(value: 48),
                    controller: controller.confirmPassword,
                    backgroundColor: AppColors.blue50,
                    borderRadius: 6,
                    isPassword: true,
                    borderColor: Colors.transparent,
                  ),
                  //! Confirm Button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => AppButton(
            title: AppString.confirm.tr,
            height: AppSize.height(value: 48),
            backgroundColor: AppColors.blue500,
            borderColor: Colors.transparent,
            isLoading: controller.isLoading.value,
            onTap: () {
              controller.resetPassword();
            },
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
