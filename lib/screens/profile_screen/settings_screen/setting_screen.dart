import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_icon_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: AppString.settings.tr,
        showAction: false,
        showLeading: true,
        backgroundColor: AppColors.white200,
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          children: [
            Gap(height: AppSize.height(value: 20)),
            AppButtonWithIcon(
              buttonText: AppString.changePasswod.tr,
              svgIconPath: AppIcons.changePassword,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.changePasswordScreen);
              },
            ),
            Gap(height: AppSize.height(value: 15)),
            AppButtonWithIcon(
              buttonText: AppString.privacyPolicy.tr,
              svgIconPath: AppIcons.privacyPolicy,
              textColor: AppColors.blue500,
              onPressed: () {
                Get.toNamed(AppRoute.privacyPolicyScreen);
              },
            ),
            Gap(height: AppSize.height(value: 15)),
            AppButtonWithIcon(
              buttonText: AppString.deleteAccount.tr,
              svgIconPath: AppIcons.deleteAccount,
              textColor: AppColors.blue500,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return deleteAccountDialog(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget deleteAccountDialog(BuildContext context) {
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFEE4E2), // Light red background
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 30),
        ),
        const SizedBox(height: 16),
        AppText(
          text: AppString.deleteAccount.tr,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        const SizedBox(height: 8),
        AppText(
          text: AppString.areyouSuretoDeleteAccount.tr,
          fontSize: 14,
          color: Colors.grey,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: AppText(
                  text: AppString.cancel.tr,
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Perform delete action
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: AppText(
                  text: AppString.deleteAccount.tr,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
