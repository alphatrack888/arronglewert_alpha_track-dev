import 'package:alpha_track/core/app_route/app_route.dart';
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

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.signUp.tr,
        backgroundColor: AppColors.white200,
        showLeading: true,
        showAction: false,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(height: AppSize.height(value: 20)),
            Center(
              child: Column(
                children: [
                  AppText(
                    text: AppString.welcomeToAlphaTrack.tr,
                    fontSize: AppSize.width(value: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black500,
                    height: 1.5,
                  ),
                  Gap(height: AppSize.height(value: 05)),
                  AppText(
                    text: AppString.createAccountToAccess.tr,
                    fontSize: AppSize.width(value: 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.black500,
                    height: 1.5,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Gap(height: AppSize.height(value: 21)),
            //! Name Field
            AppText(
              text: AppString.fullName.tr,
              fontSize: AppSize.width(value: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourFullName.tr,
              height: AppSize.height(value: 48),
              controller: TextEditingController(),
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.name,
            ),
            Gap(height: AppSize.height(value: 12)),
            //! Email Field
            AppText(
              text: AppString.email.tr,
              fontSize: AppSize.width(value: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourEmail.tr,
              height: AppSize.height(value: 48),
              controller: TextEditingController(),
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.emailAddress,
            ),
            Gap(height: AppSize.height(value: 12)),
            //! Contact Number
            AppText(
              text: AppString.contactNumber.tr,
              fontSize: AppSize.width(value: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourContactNumber.tr,
              height: AppSize.height(value: 48),
              controller: TextEditingController(),
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.phone,
            ),
            Gap(height: AppSize.height(value: 12)),
            //! Designation Field
            AppText(
              text: AppString.designation.tr,
              fontSize: AppSize.width(value: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.black500,
            ),
            Gap(height: AppSize.height(value: 05)),
            CustomTextField(
              hintText: AppString.enterYourDesignation.tr,
              height: AppSize.height(value: 48),
              controller: TextEditingController(),
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.name,
            ),
            Gap(height: AppSize.height(value: 12)),
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
              isPassword: true,
              controller: TextEditingController(),
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.visiblePassword,
            ),
            Gap(height: AppSize.height(value: 12)),
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
              isPassword: true,
              height: AppSize.height(value: 48),
              controller: TextEditingController(),
              backgroundColor: AppColors.blue50,
              borderRadius: 6,
              borderColor: Colors.transparent,
              keyboardType: TextInputType.visiblePassword,
            ),
            Gap(height: AppSize.height(value: 30)),
            //! Sign Up Button
            AppButton(
              title: AppString.signUp.tr,
              height: AppSize.height(value: 48),
              backgroundColor: AppColors.blue500,
              borderColor: Colors.transparent,
              onTap: () {},
            ),
            //! Already have an account
            Gap(height: AppSize.height(value: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: AppString.alreadyhaveAnAccount.tr,
                  fontSize: AppSize.width(value: 14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.black500,
                ),
                Gap(width: AppSize.width(value: 05)),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoute.loginScreen);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: AppText(
                    text: AppString.login.tr,
                    fontSize: AppSize.width(value: 15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.blue500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
