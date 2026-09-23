import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChanagePasswordController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  RxBool isLoading = false.obs;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  void changePassword() async {
    try {
      isLoading(true);
      final response = await authRepository.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      if (response) {
        AppSnackBar.success("Successfully Changed the Password");
      }
    } catch (e) {
      AppSnackBar.error("Failed to change password");
    } finally {
      isLoading(false);
    }
  }
}
