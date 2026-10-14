import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Filled primary pill button ("Start Tracking", "Log In", "Continue").
///
/// Presentation only — the caller supplies [onTap]; the wired action is
/// unchanged. Set [isLoading] to show the existing wave-dots loader.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.height = 52,
    this.width = double.infinity,
    this.color,
    this.textColor,
    this.radius = 9999,
    this.isTranslate = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final String? svgIcon;
  final double height;
  final double? width;
  final Color? color;
  final Color? textColor;
  final double radius;
  final bool isTranslate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: isLoading
            ? LoadingAnimationWidget.waveDots(color: AppColors.white50, size: 28)
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (svgIcon != null) ...[
                    SvgPicture.asset(svgIcon!, width: 18, height: 18),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 18, color: textColor ?? AppColors.white50),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    isTranslate ? label.tr : label,
                    style: AppTextStyles.button.copyWith(
                      color: textColor ?? AppColors.white50,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined secondary pill button ("Add Note", "Cancel").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.svgIcon,
    this.height = 52,
    this.width = double.infinity,
    this.color,
    this.radius = 9999,
    this.isTranslate = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? svgIcon;
  final double height;
  final double? width;
  final Color? color;
  final double radius;
  final bool isTranslate;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgIcon != null) ...[
              SvgPicture.asset(svgIcon!, width: 18, height: 18),
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
            ],
            Text(
              isTranslate ? label.tr : label,
              style: AppTextStyles.button.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
