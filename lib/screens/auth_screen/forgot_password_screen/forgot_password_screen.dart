import 'package:alpha_track/screens/auth_screen/forgot_password_screen/controller/forgot_password_controller.dart';
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

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final ForgotPasswordController controller =
      Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.forgotPassword.tr,
        showLeading: true,
        showAction: false,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Gap(height: AppSize.height(value: 30)),
            Image.asset(
              AppImages.forgotPassword,
              height: AppSize.height(value: 200),
              width: AppSize.width(value: 200),
            ),
            Gap(height: AppSize.height(value: 36)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
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
                  Gap(height: AppSize.height(value: 10)),
                  Center(
                    child: AppText(
                      text: AppString.forgotPassword.tr,
                      fontSize: AppSize.width(value: 18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black500,
                    ),
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  Center(
                    child: AppText(
                      text: AppString.noWorriesEnterYourEmail.tr,
                      fontSize: AppSize.width(value: 14),
                      fontWeight: FontWeight.w400,
                      color: AppColors.black400,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(height: AppSize.height(value: 20)),
                  AppText(
                    text: AppString.email.tr,
                    fontSize: AppSize.width(value: 16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                  Gap(height: AppSize.height(value: 05)),
                  CustomTextField(
                    hintText: AppString.enterYourEmail.tr,
                    height: AppSize.height(value: 48),
                    controller: controller.email,
                    backgroundColor: AppColors.blue50,
                    borderRadius: 6,
                    borderColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Obx(
          () => AppButton(
            backgroundColor: AppColors.blue500,
            height: 48,
            title: AppString.sentOtpCode.tr,
            isLoading: controller.isLoading.value,
            fontSize: AppSize.width(value: 14),
            onTap: () {
              controller.sendForgotPasswordRequest();
            },
          ),
        ),
      ),
    );
  }
}
