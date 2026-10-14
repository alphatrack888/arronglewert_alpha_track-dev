import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Live password acceptance criteria checklist.
///
/// Listens to [controller] and recolors each rule green (satisfied) or
/// red (unsatisfied) as the user types, matching the Figma "New Password"
/// designs on the Reset Password and Change Password screens.
class DsPasswordCriteria extends StatelessWidget {
  const DsPasswordCriteria({super.key, required this.controller});

  final TextEditingController controller;

  static bool isValid(String value) =>
      value.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(value) &&
      RegExp(r'[a-z]').hasMatch(value) &&
      RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_\-\[\]\\/+=~`;]').hasMatch(value);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Rule(
              text: 'criteriaMinChars'.tr,
              satisfied: text.length >= 8,
            ),
            const SizedBox(height: 8),
            _Rule(
              text: 'criteriaUppercase'.tr,
              satisfied: RegExp(r'[A-Z]').hasMatch(text),
            ),
            const SizedBox(height: 8),
            _Rule(
              text: 'criteriaLowercase'.tr,
              satisfied: RegExp(r'[a-z]').hasMatch(text),
            ),
            const SizedBox(height: 8),
            _Rule(
              text: 'criteriaNumberSymbol'.tr,
              satisfied: RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_\-\[\]\\/+=~`;]')
                  .hasMatch(text),
            ),
          ],
        );
      },
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.text, required this.satisfied});

  final String text;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    final color = satisfied ? AppColors.success : AppColors.danger;
    return Row(
      children: [
        Icon(
          satisfied ? LucideIcons.check : LucideIcons.x,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
