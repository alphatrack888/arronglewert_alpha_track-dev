import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreenFinal extends StatelessWidget {
  const OnboardingScreenFinal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white100,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(height: AppSize.height(value: 120)),
              Image.asset(
                AppImages.logo,
                height: AppSize.height(value: 170),
                width: AppSize.width(value: 170),
              ),
              Gap(height: AppSize.height(value: 10)),
              AppText(
                text: AppString.appName,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.blue500,
              ),
              Gap(height: AppSize.height(value: 20)),
              AppText(
                text: AppString.readyToGetStarted,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
              ),
              Gap(height: AppSize.height(value: 10)),
              AppText(
                text: AppString.toUnlockAllFeatures,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.black300,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(height: AppSize.height(value: 50)),
              //! Login Button
              AppButton(
                title: AppString.login,
                onTap: () {
                  Get.toNamed(AppRoute.loginScreen);
                },
                titleColor: AppColors.white100,
                backgroundColor: AppColors.blue500,
              ),
              Gap(height: AppSize.height(value: 20)),
              // //! SignUp Button
              // AppButton(
              //   title: AppString.signUp,
              //   titleColor: AppColors.blue500,
              //   backgroundColor: AppColors.white100,
              //   borderColor: AppColors.blue500,
              //   onTap: () {
              //     Get.toNamed(AppRoute.signupScreen);
              //   },
              // ),
              // Gap(height: AppSize.height(value: 50)),
              // //! Continue As Guest
              // InkWell(
              //   splashColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   onTap: () {
              //     Get.toNamed(AppRoute.homeScreen);
              //   },
              //   child: AppText(
              //     text: AppString.continueAsGuest,
              //     fontSize: 24,
              //     fontWeight: FontWeight.w500,
              //     color: AppColors.blue500,
              //     maxLines: 2,
              //     textAlign: TextAlign.center,
              //     overflow: TextOverflow.ellipsis,
              //     decoration: TextDecoration.underline,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
