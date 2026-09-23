import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/auth_screen/login_screen/controller/login_screen_controller.dart';
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

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final controller = Get.find<LoginScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        backgroundColor: AppColors.white200,
        showLeading: true,
        title: AppString.login.tr,
        showAction: false,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(height: AppSize.height(value: 40)),
            Center(
              child: AppText(
                text: AppString.loginToAccessYourTime.tr,
                fontSize: AppSize.width(value: 14),
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
                height: 1.5,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Gap(height: AppSize.height(value: 35)),
            //! Email Field
            AppText(
              text: AppString.email.tr,
              fontSize: AppSize.width(value: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
              height: 1.5,
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
            Gap(height: AppSize.height(value: 12)),
            //! Password Field
            AppText(
              text: AppString.password.tr,
              fontSize: AppSize.width(value: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
              height: 1.5,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourPassword.tr,
              height: AppSize.height(value: 48),
              controller: controller.password,
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              isPassword: true,
            ),
            Gap(height: AppSize.height(value: 12)),
            //! Remember Me and Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.isCheked.value,
                        activeColor: AppColors.blue500,
                        onChanged: (value) {
                          controller.isCheked.value = value!;
                        },
                      ),
                    ),
                    AppText(
                      text: AppString.rememberMe.tr,
                      fontSize: AppSize.width(value: 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.black500,
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoute.forgotPasswordScreen);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: AppText(
                    text: AppString.forgotPassword.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.black500,
                  ),
                ),
              ],
            ),
            //! Login Button
            Gap(height: AppSize.height(value: 30)),
            Obx(
              () => AppButton(
                title: AppString.login.tr,
                titleColor: AppColors.white100,
                backgroundColor: AppColors.blue500,
                isLoading: controller.isLoading.value,
                onTap: () {
                  controller.loginEmployee();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
