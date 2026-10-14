// Throwaway preview harness — NOT part of the shipping app.
// Renders real redesigned screens on Chrome so we can screenshot them without
// the backend. Run: flutter run -t lib/preview/preview_main.dart -d chrome
import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/screens/onboarding_screen/onboarding_screen.dart';
import 'package:alpha_track/screens/onboarding_screen/onboarding_screen_final.dart';
import 'package:alpha_track/screens/onboarding_screen/onboarding_screen_two.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(const PreviewApp());

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: const Locale('english'),
      fallbackLocale: const Locale('english'),
      home: Scaffold(
        backgroundColor: const Color(0xFF2B2F36),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _frame('Onboarding — Welcome', const OnboardingScreen()),
              _frame('Onboarding — Carousel', OnboardingScreenTwo()),
              _frame('Ready to get started', const OnboardingScreenFinal()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frame(String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.bodySemibold.copyWith(color: AppColors.white50)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.black, width: 8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(width: 360, height: 760, child: screen),
            ),
          ),
        ],
      ),
    );
  }
}
