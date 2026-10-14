import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Small pill badge used for statuses like "Running", "Default", "Overtime".
///
/// Pure presentation — pass the label + colours from the caller's state so it
/// stays decoupled from any business logic.
class DsChip extends StatelessWidget {
  const DsChip({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.background,
    this.showDot = true,
  });

  /// Green "Running" chip.
  factory DsChip.success(String label) =>
      DsChip(label: label, color: AppColors.success);

  /// Orange "Overtime" chip.
  factory DsChip.warning(String label) =>
      DsChip(label: label, color: AppColors.warning);

  /// Blue "Default" chip.
  factory DsChip.primary(String label) =>
      DsChip(label: label, color: AppColors.primary);

  /// Red "Rejected" chip.
  factory DsChip.danger(String label) =>
      DsChip(label: label, color: AppColors.danger);

  /// Neutral grey chip (no dot), e.g. "Past".
  factory DsChip.neutral(String label) => DsChip(
    label: label,
    color: AppColors.textMuted,
    background: AppColors.neutralSoft,
    showDot: false,
  );

  final String label;
  final Color color;
  final Color? background;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
