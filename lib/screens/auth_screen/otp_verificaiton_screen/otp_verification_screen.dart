import 'package:alpha_track/screens/auth_screen/otp_verificaiton_screen/controller/otp_verification_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_appbar/app_appbar_auth.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
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
      appBar: AuthAppBar(
        backgroundColor: AppColors.white200,
        showLeading: true,
        title: AppString.verifyOtp.tr,
        showAction: false,
      ),
      backgroundColor: AppColors.white100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(height: AppSize.height(value: 30)),
            Image.asset(
              AppImages.otpScreen,
              width: AppSize.width(value: 200),
              height: AppSize.height(value: 200),
            ),
            Gap(height: AppSize.height(value: 40)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.white50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    blurRadius: 5.0,
                    offset: Offset(0, -15),
                  ),
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    offset: Offset(0, -10),
                  ),
                  BoxShadow(color: Colors.white, offset: Offset(0, -10)),
                ],
              ),
              child: Column(
                children: [
                  Gap(height: AppSize.height(value: 10)),
                  AppText(
                    text: AppString.verifyYourAccount.tr,
                    fontSize: AppSize.width(value: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.black500,
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  AppText(
                    text: AppString.weHaveserntaVerifucation.tr,
                    fontSize: AppSize.width(value: 12),
                    fontWeight: FontWeight.w400,
                    color: AppColors.black600,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  // Solution 1: Use both onCodeChanged and onSubmit
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: AppColors.black400,
                    fillColor: AppColors.white100,
                    keyboardType: TextInputType.number,
                    showFieldAsBox: true,
                    // Capture OTP as user types
                    onCodeChanged: (String code) {
                      controller.updateOtp(code);
                    },
                    // Also capture when all fields are filled
                    onSubmit: (String verificationCode) {
                      controller.setCompleteOtp(verificationCode);
                    },
                    decoration: InputDecoration(
                      fillColor: AppColors.blue400,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.black400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.blue400,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Gap(height: AppSize.height(value: 10)),
                  Obx(() {
                    if (!controller.canResend.value) {
                      return AppText(
                        text:
                            "${AppString.resentIn.tr} in ${controller.timer.value}s".tr,
                        fontSize: AppSize.width(value: 14),
                        fontWeight: FontWeight.w400,
                        color: AppColors.blue400,
                      );
                    } else {
                      return TextButton(
                        onPressed: controller.resendOtp,
                        child: AppText(
                          text: AppString.resendOtp.tr,
                          fontSize: AppSize.width(value: 14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue400,
                        ),
                      );
                    }
                  }),
                  Gap(height: AppSize.height(value: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => AppButton(
            height: 48,
            title: AppString.continuee.tr,
            titleColor: AppColors.white50,
            backgroundColor: AppColors.blue500,
            isLoading: controller.isLoading.value,
            onTap: () {
              controller.verifyOtp();
            },
          ),
        ),
      ),
    );
  }
}
