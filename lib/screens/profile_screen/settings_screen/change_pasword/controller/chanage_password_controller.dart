import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
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

  void _clear() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// Returns true on success so the screen can pop and clear the form.
  Future<bool> changePassword() async {
    final oldPass = oldPasswordController.text;
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    // Validation with clear, per-field feedback.
    if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      AppSnackBar.error('vFillPasswordFields'.tr);
      return false;
    }
    if (newPass.length < 8) {
      AppSnackBar.error('vPasswordMin8'.tr);
      return false;
    }
    if (newPass != confirm) {
      AppSnackBar.error('vPasswordMismatch'.tr);
      return false;
    }
    if (newPass == oldPass) {
      AppSnackBar.error('vPasswordSame'.tr);
      return false;
    }

    // Demo/review builds have no auth session — confirm success locally.
    if (kDemoMode) {
      AppSnackBar.success('passwordChanged'.tr);
      _clear();
      return true;
    }

    try {
      isLoading(true);
      final response = await authRepository.changePassword(
        oldPassword: oldPass,
        newPassword: newPass,
        confirmPassword: confirm,
      );
      if (response) {
        AppSnackBar.success('passwordChanged'.tr);
        _clear();
        return true;
      }
      AppSnackBar.error('passwordChangeFailedOld'.tr);
      return false;
    } catch (e) {
      AppSnackBar.error('passwordChangeFailed'.tr);
      return false;
    } finally {
      isLoading(false);
    }
  }
}
