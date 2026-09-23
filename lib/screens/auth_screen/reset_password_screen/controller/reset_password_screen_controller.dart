import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreenController extends GetxController {
  final AuthRepository authRepository = Get.find<AuthRepository>();
  RxBool isLoading = false.obs;
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> resetPassword() async {
    try {
      isLoading(true);
      bool result = await authRepository.resetPassword(
        newPassword: newPassword.text.toString(),
        confirmPassword: confirmPassword.text.toString(),
      );
      if(result){
        AppSnackBar.success("Password reset successfully");
      }
    } catch (e) {
      appLog(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
