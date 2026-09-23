import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  ApiServices apiServices = ApiServices.instance;
  StorageServices storageServices = StorageServices.instance;

  //! Login Employee
  Future<bool> loginEmployee({
    required String email,
    required String password,
  }) async {
    try {
      // Make the API call directly with proper error handling
      final response = await _makeDirectLoginRequest(email, password);

      appLog("Login API Response: $response");

      if (response != null) {
        final statusCode = response['statusCode'];
        final responseData = response['data'];

        if (statusCode == 407 && responseData['success'] == true) {
          // OTP flow - when API returns 407 status
          Get.toNamed(
            AppRoute.otpVerificationScreen,
            arguments: {"email": email, "screen": "login"},
          );
          AppSnackBar.customMessage(
            responseData["message"] ?? "We have sent an OTP to your email",
            color: AppColors.mediumBlue,
          );
          return true;
        } else if (statusCode == 200 &&
            responseData["data"]?["accessToken"] != null) {
          // Successful login - when API returns 200 status
          await _handleSuccessfulLogin(responseData['data']);
          return true;
        } else {
          // Handle error cases
          String errorMessage = responseData["message"] ?? "Login failed";
          AppSnackBar.error(errorMessage);
          return false;
        }
      } else {
        // Handle null response
        AppSnackBar.error("No response from server");
        return false;
      }
    } catch (e) {
      appLog("Login error: $e");
      AppSnackBar.error("An error occurred during login");
      return false;
    }
  }

  //! Make direct login request with proper error handling
  Future<Map<String, dynamic>?> _makeDirectLoginRequest(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiServices.instance.api.sendRequest.post(
        ApiUrls.employeeLogin,
        data: {"email": email, "password": password},
        options: Options(
          validateStatus: (status) {
            // Accept both success status codes and 407 as valid responses
            return (status != null &&
                ((status >= 200 && status < 300) || status == 407));
          },
        ),
      );

      return {'statusCode': response.statusCode, 'data': response.data};
    } on DioException catch (dioError) {
      // Handle the specific case where 407 might still be caught
      if (dioError.response?.statusCode == 407) {
        appLog("Handling 407 from DioException: ${dioError.response?.data}");
        return {'statusCode': 407, 'data': dioError.response?.data};
      }

      // Handle other Dio errors
      appLog("DioException in login: ${dioError.message}");
      if (dioError.response?.data != null) {
        AppSnackBar.error(dioError.response?.data["message"] ?? "Login failed");
      }
      return null;
    } catch (e) {
      appLog("General error in login request: $e");
      return null;
    }
  }

  //! Otp Verifications
  Future<bool> otpVerification({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await apiServices.apiPostServicesWithOtp(
        url: ApiUrls.verifyAccount,
        body: {"email": email, "oneTimeCode": otp},
      );

      appLog("OTP Verification Response: $response");

      if (response != null &&
          response["success"] == true &&
          response["data"]?["accessToken"] != null) {
        // Successful OTP verification
        await _handleSuccessfulLogin(response['data']);
        return true;
      } else {
        // Handle error cases
        String errorMessage = response?["message"] ?? "OTP verification failed";
        AppSnackBar.error(errorMessage);
        return false;
      }
    } catch (e) {
      appLog("OTP verification error: $e");
      AppSnackBar.error("An error occurred during OTP verification");
      return false;
    }
  }

  //! Verify Forgot Password OTP
  Future<bool> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await apiServices.apiPostServices(
        url: ApiUrls.verifyAccount,
        body: {"email": email, "oneTimeCode": otp},
      );

      appLog("Forgot Password OTP Verification Response: $response");

      if (response != null && response["success"] == true) {
        // Navigate to reset password screen with email and verified OTP
        Get.offNamed(
          AppRoute.resetPasswordScreen,
          arguments: {"email": email, "otp": otp},
        );
        AppSnackBar.success("OTP verified successfully");
        return true;
      } else {
        // Handle error cases
        String errorMessage = response?["message"] ?? "OTP verification failed";
        AppSnackBar.error(errorMessage);
        return false;
      }
    } catch (e) {
      appLog("Forgot Password OTP verification error: $e");
      AppSnackBar.error("An error occurred during OTP verification");
      return false;
    }
  }

  //! Handle Successful login
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> data) async {
    appLog(data);
    final String accessToken = data["accessToken"];
    appLog("accessToken from login api $accessToken");

    // Save token and wait for completion
    await storageServices.setAccessToken(accessToken);

    // Verify token was saved
    final savedToken = storageServices.getAccessToken();
    appLog(
      "Verified saved token: ${savedToken.isNotEmpty ? 'Token saved successfully' : 'ERROR: Token not saved!'}",
    );

    final String refreshToken = data["accessToken"];
    appLog("refreshToken from login api $refreshToken");
    await storageServices.setRefreshToken(refreshToken);

    final String role = data["role"];
    appLog("role from login api $role");
    await storageServices.setUserRole(role);

    // Add a small delay to ensure storage is fully committed
    await Future.delayed(const Duration(milliseconds: 100));

    Get.offAllNamed(AppRoute.bottomNavigation);
    AppSnackBar.success("Login Successfully");
  }

  //! Resend Otp
  Future<bool> resendOtp({
    required String email,
    required String authType,
  }) async {
    try {
      final response = await apiServices.apiPostServices(
        url: ApiUrls.resendOtp,
        body: {"email": email, "authType": authType},
      );
      if (response != null && response["success"] == true) {
        AppSnackBar.customMessage(
          response["message"] ?? "OTP resent successfully",
          color: AppColors.mediumBlue,
        );
      }
    } catch (e) {
      appLog("Resend OTP error: $e");
      AppSnackBar.error("An error occurred while resending OTP");
      return false;
    }
    return true;
  }

  //! Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await apiServices.apiPostServices(
        url: ApiUrls.forgotPassword,
        body: {"email": email},
      );
      if (response != null && response["success"] == true) {
        Get.toNamed(
          AppRoute.otpVerificationScreen,
          arguments: {"email": email, "screen": "forgotPassword"},
        );
        AppSnackBar.customMessage(
          response["message"] ?? "We have sent an OTP to your email",
          color: AppColors.mediumBlue,
        );
        return true;
      } else {
        String errorMessage = response?["message"] ?? "Failed to send OTP";
        AppSnackBar.error(errorMessage);
        return false;
      }
    } catch (e) {
      appLog("Forgot Password error: $e");
      AppSnackBar.error("An error occurred during the process");
      return false;
    }
  }

  //!Reset Password
  Future<bool> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiServices.apiPostServices(
        url: ApiUrls.resetPassword,
        body: {"newPassword": newPassword, "confirmPassword": confirmPassword},
      );
      if (response != null && response["success"] == true) {
        Get.toNamed(AppRoute.loginScreen);
        AppSnackBar.customMessage(
          response["message"] ?? "Password reset successfully",
          color: AppColors.mediumBlue,
        );
        return true;
      } else {
        String errorMessage =
            response?["message"] ?? "Failed to reset password";
        AppSnackBar.error(errorMessage);
        return false;
      }
    } catch (e) {
      appLog("Reset Password error: $e");
      AppSnackBar.error("An error occurred during the process");
      return false;
    }
  }

  //! Change Password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiServices.apiPostServices(
        url: ApiUrls.changePasswrod,
        body: {
          "currentPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
      if (response != null && response["success"] == true) {
        AppSnackBar.customMessage(
          response["message"] ?? "Password changed successfully",
          backgroundColor: AppColors.mediumBlue,
        );
        return true;
      }
      return false;
    } catch (e) {
      appLog("Change Password error: $e");
      return false;
    }
  }
}
