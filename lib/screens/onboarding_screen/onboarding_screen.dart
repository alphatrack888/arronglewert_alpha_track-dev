import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(AppImages.logo, height: 200, width: 200),
            Gap(height: AppSize.height(value: 30)),
            AppText(
              text: AppString.welcomeToAlphaTrack,
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.black400,
            ),
            Gap(height: AppSize.height(value: 10)),
            AppText(
              text: AppString.youAllInOneSolution,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black300,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Gap(height: AppSize.height(value: 100)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 70),
        child: AppButton(
          title: AppString.getStarted,
          onTap: () {
            Get.toNamed(AppRoute.onboardingScreenTwo);
          },
          width: double.infinity,
          backgroundColor: AppColors.blue500,
          titleColor: AppColors.white100,
        ),
      ),
    );
  }
}
