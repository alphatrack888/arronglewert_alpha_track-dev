import 'package:alpha_track/screens/profile_screen/language_screen/controller/language_screen_controller.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_icons/app_icons.dart';
import '../../../utils/app_size/app_gap.dart';
import '../../../utils/app_string/app_string.dart';
import '../../../widgets/app_appbar/app_appbar_auth.dart';
import '../../../widgets/app_button/app_icon_button.dart';

class LanguageScreen extends StatelessWidget {
  LanguageScreen({super.key});
  final controller = Get.find<LanguageScreenController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.languageChanges.tr,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          children: [
            Gap(height: AppSize.height(value: 30)),
            AppButtonWithIcon(
              height: AppSize.height(value: 55),
              buttonText: AppString.english,
              svgIconPath: AppIcons.englishLanguage,
              textColor: AppColors.blue500,
              onPressed: () {
                controller.changeLanguage('english');
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              height: AppSize.height(value: 55),
              buttonText: AppString.german,
              svgIconPath: AppIcons.germanLanguage,
              textColor: AppColors.blue500,
              onPressed: () {
                controller.changeLanguage('german');
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              height: AppSize.height(value: 55),
              buttonText: AppString.arabic,
              svgIconPath: AppIcons.arabicLanguage,
              textColor: AppColors.blue500,
              onPressed: () {
                controller.changeLanguage('arabic');
              },
            ),
            Gap(height: AppSize.height(value: 12)),
            AppButtonWithIcon(
              height: AppSize.height(value: 55),
              buttonText: AppString.romanian,
              svgIconPath: AppIcons.romanianLanguage,
              textColor: AppColors.blue500,
              onPressed: () {
                controller.changeLanguage('romanian');
              },
            ),
          ],
        ),
      ),
    );
  }
}
