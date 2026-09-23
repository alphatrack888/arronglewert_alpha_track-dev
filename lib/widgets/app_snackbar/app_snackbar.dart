import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static error(String parameterValue, {SnackPosition? snackPosition}) {
    Get.showSnackbar(
      GetSnackBar(
        isDismissible: true,
        snackPosition: snackPosition ?? SnackPosition.TOP,
        backgroundColor: AppColors.red.withValues(alpha: 0.9),
        animationDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 1),
        messageText: AppText(text: parameterValue, color: AppColors.white50),
        borderRadius: AppSize.width(value: 5.0),
        padding: EdgeInsets.all(AppSize.width(value: 10.0)),
        margin: EdgeInsets.symmetric(
          horizontal: AppSize.width(value: 20.0),
          vertical: AppSize.width(value: 20),
        ),
      ),
    );
  }

  static success(
    String parameterValue, {
    SnackPosition? snackPosition,
    Duration? duration,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: AppColors.green,
        animationDuration: const Duration(seconds: 1),
        duration: duration ?? const Duration(seconds: 1),
        snackPosition: snackPosition ?? SnackPosition.TOP,
        messageText: AppText(
          text: parameterValue,
          color: AppColors.white50,
          fontWeight: FontWeight.w500,
        ),
        borderRadius: AppSize.width(value: 5.0),
        padding: EdgeInsets.all(AppSize.width(value: 10.0)),
        margin: EdgeInsets.symmetric(
          horizontal: AppSize.width(value: 20.0),
          vertical: AppSize.width(value: 20),
        ),
      ),
    );
  }

  static message(
    String parameterValue, {
    Color? backgroundColor,
    Color? color,
    SnackPosition? snackPosition,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: backgroundColor ?? AppColors.blue600,
        animationDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 1),
        snackPosition: snackPosition ?? SnackPosition.TOP,
        messageText: AppText(
          text: parameterValue,
          color: color ?? AppColors.white300,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        borderRadius: AppSize.width(value: 5.0),
        padding: EdgeInsets.all(AppSize.width(value: 10.0)),
        margin: EdgeInsets.symmetric(
          horizontal: AppSize.width(value: 20.0),
          vertical: AppSize.width(value: 20),
        ),
      ),
    );
  }

  static customMessage(
    String parameterValue, {
    Color? backgroundColor,
    Color? color,
    SnackPosition? snackPosition,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: backgroundColor ?? AppColors.blue600,
        animationDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 3),
        snackPosition: snackPosition ?? SnackPosition.TOP,
        messageText: AppText(
          text: parameterValue,
          color: color ?? AppColors.white100,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        borderRadius: AppSize.width(value: 5.0),
        padding: EdgeInsets.all(AppSize.width(value: 10.0)),
        margin: EdgeInsets.symmetric(
          horizontal: AppSize.width(value: 20.0),
          vertical: AppSize.width(value: 20),
        ),
      ),
    );
  }
}
