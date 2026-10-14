import 'package:alpha_track/screens/auth_screen/otp_verificaiton_screen/controller/otp_verification_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_auth_header.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});
  final OtpVerificationScreenController controller =
      Get.find<OtpVerificationScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsAuthHeader(
                title: AppString.verifyOtp.tr,
                subtitle: AppString.weHaveserntaVerifucation.tr,
              ),
              const SizedBox(height: 32),
              OtpTextField(
                numberOfFields: 6,
                borderColor: AppColors.stroke,
                focusedBorderColor: AppColors.primary,
                fillColor: AppColors.surface,
                filled: true,
                keyboardType: TextInputType.number,
                showFieldAsBox: true,
                borderRadius: BorderRadius.circular(12),
                // Capture OTP as user types
                onCodeChanged: (String code) {
                  controller.updateOtp(code);
                },
                // Also capture when all fields are filled
                onSubmit: (String verificationCode) {
                  controller.setCompleteOtp(verificationCode);
                },
                decoration: InputDecoration(
                  fillColor: AppColors.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.stroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Obx(() {
                  if (!controller.canResend.value) {
                    return Text(
                      "${AppString.resentIn.tr} in ${controller.timer.value}s"
                          .tr,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted),
                    );
                  } else {
                    return TextButton(
                      onPressed: controller.resendOtp,
                      child: Text(
                        AppString.resendOtp.tr,
                        style: AppTextStyles.bodySemibold
                            .copyWith(color: AppColors.primary),
                      ),
                    );
                  }
                }),
              ),
              const SizedBox(height: 28),
              //! Continue Button
              Obx(
                () => PrimaryButton(
                  label: AppString.continuee.tr,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.verifyOtp(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
