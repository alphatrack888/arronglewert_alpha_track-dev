import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// App-wide toast/snackbar, restyled for the 2026 redesign.
///
/// The public API (static `error` / `success` / `message` / `customMessage`) is
/// unchanged so the ~50 existing call sites keep working — only the look is new:
/// a white rounded card with a coloured leading icon badge, soft shadow and the
/// Hanken Grotesk type scale. Status colours come from the new design tokens
/// (`AppColors.success` / `danger` / `primary`).
class AppSnackBar {
  static const Duration _defaultDuration = Duration(seconds: 2);

  static void _show({
    required String text,
    required Color accent,
    required IconData icon,
    SnackPosition? snackPosition,
    Duration? duration,
  }) {
    // Close any visible snackbar so they don't stack on rapid calls.
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    Get.showSnackbar(
      GetSnackBar(
        isDismissible: true,
        snackPosition: snackPosition ?? SnackPosition.TOP,
        backgroundColor: AppColors.surface,
        animationDuration: const Duration(milliseconds: 350),
        duration: duration ?? _defaultDuration,
        borderRadius: 14,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        messageText: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static error(
    String parameterValue, {
    SnackPosition? snackPosition,
    Duration? duration,
  }) {
    _show(
      text: parameterValue,
      accent: AppColors.danger,
      icon: LucideIcons.circleAlert,
      snackPosition: snackPosition,
      duration: duration,
    );
  }

  static success(
    String parameterValue, {
    SnackPosition? snackPosition,
    Duration? duration,
  }) {
    _show(
      text: parameterValue,
      accent: AppColors.success,
      icon: LucideIcons.circleCheck,
      snackPosition: snackPosition,
      duration: duration,
    );
  }

  static message(
    String parameterValue, {
    Color? backgroundColor,
    Color? color,
    SnackPosition? snackPosition,
  }) {
    _show(
      text: parameterValue,
      accent: color ?? AppColors.primary,
      icon: LucideIcons.info,
      snackPosition: snackPosition,
    );
  }

  static customMessage(
    String parameterValue, {
    Color? backgroundColor,
    Color? color,
    SnackPosition? snackPosition,
  }) {
    _show(
      text: parameterValue,
      accent: color ?? AppColors.primary,
      icon: LucideIcons.info,
      snackPosition: snackPosition,
      duration: const Duration(seconds: 3),
    );
  }
}
