import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OnboardingScreenFinal extends StatelessWidget {
  const OnboardingScreenFinal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Centered gradient brand lockup — matches Figma "Get Started"
              // header ("Stacked lockup_Gradient", 239 wide).
              Center(
                child: SvgPicture.asset(
                  AppImages.logoStackedGradient,
                  width: 239,
                  semanticsLabel: 'AlphaTrack',
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'onbReady'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 10),
              Text(
                'onbReadySub'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, height: 1.5),
              ),
              const Spacer(flex: 3),
              //! Login Button — unchanged destination
              PrimaryButton(
                label: AppString.login,
                onTap: () async {
                  await StorageServices.instance.setOnboardScreen();
                  Get.toNamed(AppRoute.loginScreen);
                },
              ),
              const SizedBox(height: 14),
              //! Create Account
              SecondaryButton(
                label: AppString.signUp,
                onTap: () async {
                  await StorageServices.instance.setOnboardScreen();
                  Get.toNamed(AppRoute.signupScreen);
                },
              ),
              const SizedBox(height: 18),
              //! Continue as Guest — browse UI without login (no demo data in release).
              GestureDetector(
                onTap: () => Get.toNamed(AppRoute.bottomNavigation),
                child: Text(
                  AppString.continueAsGuest.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySemibold
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
