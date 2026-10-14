import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsAuthHeader(title: AppString.privacyPolicy.tr),
              const SizedBox(height: 24),
              Text(
                AppString.privacyPolicyHeading.tr,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 16),
              AppText(
                text: AppString.privacyPolicyBody.tr,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                maxLines: 40,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
