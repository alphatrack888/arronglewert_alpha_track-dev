import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/onboarding_screen/widgets/onboarding_widgets.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // App locale codes are full language names (see AppTranslation). Native names
  // are shown to the user so each language reads in its own script.
  static const _languages = [
    {'code': 'english', 'name': 'English'},
    {'code': 'german', 'name': 'Deutsch'},
    {'code': 'arabic', 'name': 'العربية'},
    {'code': 'romanian', 'name': 'Română'},
  ];

  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = StorageServices.instance.getLanguage() ?? 'english';
  }

  void _selectLanguage(String code) {
    setState(() => _lang = code);
    // Update the whole app immediately and persist for the auth flow + beyond.
    Get.updateLocale(Locale(code));
    StorageServices.instance.setLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const OnboardingWordmark(),
              const Spacer(flex: 2),
              const OnboardingIllustration(asset: AppImages.onboardingWelcome),
              const SizedBox(height: 36),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'welcomeTitle'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'welcomeSubtitle'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, height: 1.5),
              ),
              const Spacer(flex: 3),
              // Language selector (Figma 103-2134) — replaces the carousel dots.
              Text(
                'selectLanguage'.tr,
                style: AppTextStyles.caption.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 8),
              _languageDropdown(),
              const SizedBox(height: 16),
              PrimaryButton(
                label: AppString.getStarted,
                onTap: () => Get.toNamed(AppRoute.onboardingScreenTwo),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageDropdown() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.globe, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lang,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(LucideIcons.chevronDown,
                    size: 20, color: AppColors.textMuted),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                items: _languages
                    .map((l) => DropdownMenuItem(
                          value: l['code'],
                          child: Text(l['name']!, style: AppTextStyles.body),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _selectLanguage(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
