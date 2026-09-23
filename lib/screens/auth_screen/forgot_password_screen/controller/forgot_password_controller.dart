import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  RxBool isLoading = false.obs;
  final email = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> sendForgotPasswordRequest() async {
    if (email.text.trim().isEmpty) {
      AppSnackBar.error("Please enter your email");
      return;
    }
    try {
      isLoading(true);
      final result = await _authRepository.forgotPassword(
        email: email.text.trim(),
      );
      if (result) {
        Get.toNamed(
          AppRoute.otpVerificationScreen,
          arguments: {
            "email": email.text.trim(),
            "screenType": "forgotPassword",
          },
        );

        AppSnackBar.success("OTP sent successfully");
      } else {
        AppSnackBar.error("Failed to send OTP");
      }
    } catch (e) {
      AppSnackBar.error("An error occurred");
    } finally {
      isLoading(false);
    }
  }
}
