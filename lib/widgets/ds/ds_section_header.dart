import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Eyebrow section header with an optional trailing action, e.g.
/// "RECENT PROJECTS            See all".
class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.isTranslate = true,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isTranslate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isTranslate ? title.tr : title,
          style: AppTextStyles.eyebrow,
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              isTranslate ? actionLabel!.tr : actionLabel!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
