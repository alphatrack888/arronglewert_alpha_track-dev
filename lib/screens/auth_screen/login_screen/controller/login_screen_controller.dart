import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  RxBool isLoading = false.obs;
  RxBool isCheked = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> loginEmployee() async {
    try {
      if (email.text.trim().isEmpty || password.text.isEmpty) {
        AppSnackBar.error("Please fill all fields");
        return;
      }
      
      // Validate email format
      if (!GetUtils.isEmail(email.text.trim())) {
        AppSnackBar.error("Please enter a valid email address");
        return;
      }

      isLoading.value = true; 
      
      await _authRepository.loginEmployee(
        email: email.text.trim(),
        password: password.text,
      );
      
    } catch (e) {
      print("Login controller error: $e");
      AppSnackBar.error("An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}