import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreenController extends GetxController {
  final name = TextEditingController();
  final email = TextEditingController();
  final contactNumber = TextEditingController();
  final designation = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final RxBool isLoading = false.obs;

  // Self-service signup is disabled for now: the backend has no register
  // endpoint (POST /auth/register returns 404) and accounts are provisioned
  // by an administrator. Rather than call the dead endpoint, inform the user.
  // Re-enable AuthRepository.registerEmployee here once a real register
  // endpoint exists.
  Future<void> register() async {
    AppSnackBar.customMessage(
      'signupAdminOnly'.tr,
      color: AppColors.mediumBlue,
    );
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    contactNumber.dispose();
    designation.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
