import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Settings/menu row — matches the Figma "Menu Item" component:
/// a rounded square icon tile (soft-blue), label, and trailing chevron.
class DsMenuItem extends StatelessWidget {
  const DsMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primarySoft,
    this.labelColor = AppColors.textPrimary,
    this.showChevron = true,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBackground;
  final Color labelColor;
  final bool showChevron;

  /// Optional trailing pill (e.g. "Soon") shown in place of the chevron.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // 44x44 matches the project-card avatar (DsAvatar) so the icon frames
          // read at the same weight across the app.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(color: labelColor),
            ),
          ),
          if (badge != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                badge!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (showChevron)
            const Icon(LucideIcons.chevronRight,
                size: 20, color: AppColors.textFaint),
        ],
      ),
    );
  }
}
