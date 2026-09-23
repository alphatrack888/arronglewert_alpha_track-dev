import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/error_screen/controller/erro_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AppSize.size = size;
    return GetBuilder(
      init: ErrorScreenController(),
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => Icon(
                    controller.isInternetProblem.value
                        ? Icons.signal_wifi_off_outlined
                        : Icons.error_outline_rounded,
                    size: AppSize.width(value: 100),
                  ),
                ),
                const Gap(height: 20),
                Obx(() => AppText(text: controller.errorMessage.value)),
                Obx(
                  () => controller.isInternetProblem.value
                      ? Padding(
                          padding: EdgeInsets.all(AppSize.width(value: 10)),
                          child: const AppText(
                            text: "Check your internet connection",
                          ),
                        )
                      : const SizedBox(),
                ),
                const Gap(height: 30),

                AppButton(
                  title: "Try again",
                  onTap: () async {
                    await Get.offAllNamed(AppRoute.splashScreen);
                  },
                  height: AppSize.height(value: 55),
                  titleColor: AppColors.white100,
                  width: AppSize.width(value: 150),
                  backgroundColor: AppColors.blue500,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
