import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/onboarding_screen/controller/onboarding_screen_controller.dart';
import 'package:alpha_track/screens/onboarding_screen/widgets/onboarding_widgets.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreenTwo extends StatelessWidget {
  OnboardingScreenTwo({super.key});
  final OnboardingScreenController controller = Get.put(
    OnboardingScreenController(),
  );

  // Figma copy + illustration for the 3 feature pages (steps 2-4 of the carousel).
  static final _pages = [
    (
      title: 'onb1Title'.tr,
      subtitle:
          'onb1Sub'.tr,
      image: AppImages.onboardingTask,
    ),
    (
      title: 'onb2Title'.tr,
      subtitle:
          'onb2Sub'.tr,
      image: AppImages.onboardingNotes,
    ),
    (
      title: 'onb3Title'.tr,
      subtitle:
          'onb3Sub'.tr,
      image: AppImages.onboardingReport,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Wordmark + Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const OnboardingWordmark(),
                  GestureDetector(
                    onTap: () =>
                        Get.toNamed(AppRoute.onboardingScreenFinal),
                    child: Text(
                      AppString.skip.tr,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.updateCurrentPage,
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _OnboardingPage(
                    title: _pages[i].title,
                    subtitle: _pages[i].subtitle,
                    image: _pages[i].image,
                  ),
                ),
              ),
              // Dots — 4 total (Welcome is the first dot, carousel is 2-4).
              Obx(() => OnboardingDots(activeIndex: controller.currentPage.value + 1)),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back — circular outline button
            GestureDetector(
              onTap: () => controller.previousPage(),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.stroke),
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.primary, size: 22),
              ),
            ),
            Obx(
              () => PrimaryButton(
                width: 150,
                label: controller.currentPage.value < _pages.length - 1
                    ? AppString.next
                    : AppString.continuee,
                onTap: () => controller.nextPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.image,
  });
  final String title;
  final String subtitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OnboardingIllustration(asset: image),
        const SizedBox(height: 36),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.headline),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
