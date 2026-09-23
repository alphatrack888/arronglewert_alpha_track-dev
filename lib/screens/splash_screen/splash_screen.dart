import 'package:alpha_track/screens/splash_screen/controller/splash_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Call the Controller to handle the splash screen logic
    // ignore: unused_local_variable
    final SplashScreenController controller = Get.find<SplashScreenController>();
    Size size = MediaQuery.of(context).size;
    AppSize.size = size;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white100,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // stops: [0.1, 0.4, 0.7],
          colors: [
            Color(0xffB7E1FF),
            Color(0xffffffff),
            Color(0xffffffff),
            Color(0xffffffff),
            Color(0xffffffff),
            Color(0xffffffff),
            Color(0xffffffff),
            Color(0xffB7E1FF),
          ],
        ),
      ),
      child: Center(
        child: Image.asset(
          AppImages.appLogo,
          height: AppSize.height(value: 300),
          width: AppSize.width(value: 300),
        ),
      ),
    );
  }
}
