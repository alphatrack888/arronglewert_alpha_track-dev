import 'package:alpha_track/screens/onboarding_screen/controller/onboarding_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreenTwo extends StatelessWidget {
  OnboardingScreenTwo({super.key});
  final OnboardingScreenController controller = Get.put(
    OnboardingScreenController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white100,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    controller.updateCurrentPage(index);
                  },
                  children: [
                    letsTrackFirstTrack(),
                    trackYourTimeEffortlessly(),
                    viewYourTimeinDetails(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.height(value: 30),
                ),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        height: controller.currentPage.value == index
                            ? AppSize.height(value: 12)
                            : AppSize.height(value: 12),
                        width: controller.currentPage.value == index
                            ? AppSize.width(value: 32)
                            : AppSize.width(value: 12),
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppColors.blue500
                              : AppColors.blue200,
                          borderRadius: controller.currentPage.value == index
                              ? BorderRadius.circular(20)
                              : BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: AppSize.width(value: 28),
          right: AppSize.width(value: 28),
          bottom: AppSize.height(value: 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => AppButton(
                height: AppSize.height(value: 48),
                width: AppSize.width(value: 140),
                title: AppString.back,
                titleColor: AppColors.blue500,
                backgroundColor: AppColors.white50,
                borderColor: AppColors.blue500,
                onTap: controller.currentPage.value > 0
                    ? () => controller.previousPage()
                    : null,
              ),
            ),
            Obx(
              () => AppButton(
                height: AppSize.height(value: 48),
                width: AppSize.width(value: 140),
                title: controller.currentPage.value < 2
                    ? AppString.next
                    : AppString.getStarted,
                titleColor: AppColors.white50,
                backgroundColor: AppColors.blue500,
                onTap: () => controller.nextPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget letsTrackFirstTrack() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        AppImages.onboarding1,
        // height: AppSize.height(value: 340),
        // width: AppSize.width(value: 320),
      ),
      Gap(height: AppSize.height(value: 35)),
      AppText(
        text: AppString.letsTrackyourFirstTask,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.black400,
      ),
      Gap(height: AppSize.height(value: 05)),
      AppText(
        text: AppString.itsTimeToTryNew,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.black300,
        maxLines: 3,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget trackYourTimeEffortlessly() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(AppImages.onboarding2),
      Gap(height: AppSize.height(value: 33)),
      AppText(
        text: AppString.trackYourTimeEffortlessly,
        fontSize: AppSize.width(value: 24),
        fontWeight: FontWeight.w500,
        color: AppColors.black400,
      ),
      Gap(height: AppSize.height(value: 03)),
      AppText(
        text: AppString.easilyStartandStop,
        fontSize: AppSize.width(value: 13),
        fontWeight: FontWeight.w400,
        color: AppColors.black300,
        maxLines: 3,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget viewYourTimeinDetails() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        AppImages.onboarding3,
        // height: AppSize.height(value: 340),
        // width: AppSize.width(value: 320),
      ),
      Gap(height: AppSize.height(value: 35)),
      AppText(
        text: AppString.viewYourTimeinDetails,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.black400,
      ),
      Gap(height: AppSize.height(value: 05)),
      AppText(
        text: AppString.easilyStartandStop,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.black300,
        maxLines: 3,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
