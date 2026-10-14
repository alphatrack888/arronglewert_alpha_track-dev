import 'package:alpha_track/screens/splash_screen/controller/splash_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep the controller wiring exactly as before (handles auto-navigation).
    // ignore: unused_local_variable
    final SplashScreenController controller = Get.find<SplashScreenController>();
    Size size = MediaQuery.of(context).size;
    AppSize.size = size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Brand gradient (matches the logo SVGs' own gradient stops):
          // teal #5FAEAB → blue #2B5CC8, top-left to bottom-right.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5FAEAB), // teal
              Color(0xFF2B5CC8), // blue
            ],
          ),
        ),
        child: Center(
          // Stacked lockup (symbol + wordmark), knocked out to white on the
          // brand gradient. Matches Figma "Logo_Stacked lockup" on Splash.
          child: SvgPicture.asset(
            AppImages.logoStacked,
            width: size.width * 0.72,
            colorFilter: const ColorFilter.mode(
              AppColors.white50,
              BlendMode.srcIn,
            ),
            semanticsLabel: 'AlphaTrack',
          ),
        ),
      ),
    );
  }
}
