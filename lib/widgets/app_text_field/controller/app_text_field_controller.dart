import 'package:alpha_track/widgets/app_validator/app_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTextFieldController extends GetxController {
   final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  var emailError = ''.obs;
  var passwordError = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void onEmailValidate(String? error) {
    emailError.value = error ?? '';
  }

  void onPasswordValidate(String? error) {
    passwordError.value = error ?? '';
  }

  bool get isFormValid => emailError.isEmpty && passwordError.isEmpty;

  void submitForm() {
    // Force validation on submit
    final emailErr = AppValidators.validateEmail(emailController.text);
    final passErr = AppValidators.validatePassword(passwordController.text);
    
    emailError.value = emailErr ?? '';
    passwordError.value = passErr ?? '';

    if (isFormValid) {
      // Proceed with form submission
      print('Form is valid! Submitting...');
    }
  }
}
