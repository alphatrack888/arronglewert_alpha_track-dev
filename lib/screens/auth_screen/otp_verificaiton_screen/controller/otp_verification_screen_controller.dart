import 'dart:async';

import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';

class OtpVerificationScreenController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  RxBool isLoading = false.obs;
  String? email;
  String? screenType;

  // Make otp reactive to track changes
  RxString otp = "".obs;

  RxInt timer = 60.obs;
  RxBool canResend = false.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    // Get email and screen type from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      email = args['email'];
      screenType = args['screen'];
    }
    startTimer();
  }

  // Method to update OTP as user types
  void updateOtp(String code) {
    otp.value = code;
    appLog("OTP Updated: ${otp.value}"); // Debug log
  }

  // Method to set complete OTP when all fields are filled
  void setCompleteOtp(String verificationCode) {
    otp.value = verificationCode;
    appLog("Complete OTP Set: ${otp.value}"); // Debug log
  }

  void startTimer() {
    timer.value = 60;
    canResend.value = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timer.value > 0) {
        timer.value--;
      } else {
        canResend.value = true;
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    appLog("Verifying OTP: ${otp.value}"); // Updated to use otp.value

    if (email == null) {
      AppSnackBar.error("Email not found");
      return;
    }

    if (otp.value.isEmpty || otp.value.length < 6) {
      AppSnackBar.error("Please enter a valid 6-digit OTP");
      return;
    }

    try {
      isLoading(true);

      // Check screen type to determine which verification method to use
      if (screenType == "forgotPassword") {
        // Handle forgot password OTP verification
        final result = await _authRepository.verifyForgotPasswordOtp(
          email: email!,
          otp: otp.value, // Use otp.value instead of otp
        );
        if (!result) {
          AppSnackBar.error("OTP verification failed");
        }
      } else {
        // Handle regular login OTP verification
        final result = await _authRepository.otpVerification(
          email: email!,
          otp: otp.value, // Use otp.value instead of otp
        );
        if (!result) {
          AppSnackBar.error("OTP verification failed");
        }
      }
    } catch (e) {
      appLog("OTP Verification Error: $e");
      AppSnackBar.error("An error occurred: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendOtp() async {
    try {
      if (email == null) {
        AppSnackBar.error("Email not found");
        return;
      }
      if (!canResend.value) {
        AppSnackBar.error("Please wait before resending OTP");
        return;
      }

      isLoading(true);

      // Determine authType based on screen type
      String authType = screenType == "forgotPassword"
          ? "forgotPassword"
          : "createAccount";

      final result = await _authRepository.resendOtp(
        email: email!,
        authType: authType,
      );

      if (result) {
        AppSnackBar.success("OTP resent successfully");
        // Clear previous OTP when resending
        otp.value = "";
        startTimer();
      } else {
        AppSnackBar.error("Failed to resend OTP");
      }
    } catch (e) {
      appLog("Resend OTP Error: $e");
      AppSnackBar.error("An error occurred while resending OTP");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
