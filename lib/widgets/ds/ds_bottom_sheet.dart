import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Standard rounded bottom sheet for the 2026 redesign: a white surface with a
/// 24px top radius, a centred grab handle, an optional title row and the
/// caller-supplied content. Replaces the ad-hoc `Get.bottomSheet(Container(...))`
/// blocks scattered across the app so every sheet shares one look.
///
/// Show it with [DsBottomSheet.show] which wires up the GetX bottom sheet with
/// the correct transparent background and safe-area padding.
class DsBottomSheet extends StatelessWidget {
  const DsBottomSheet({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 20),
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: !keyboardOpen,
        child: Padding(
          padding: padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bounded = constraints.maxHeight.isFinite;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.stroke,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: Text(title!, style: AppTextStyles.title)),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 8),
                  ] else
                    const SizedBox(height: 12),
                  if (bounded)
                    Flexible(fit: FlexFit.loose, child: child)
                  else
                    child,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Present [content] as a modal bottom sheet using GetX, with the redesign's
  /// transparent backdrop so the rounded corners show. Returns whatever the
  /// sheet is closed with (via `Get.back(result: ...)`).
  static Future<T?> show<T>(Widget content, {bool isScrollControlled = true}) {
    return Get.bottomSheet<T>(
      content,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }
}

/// A single tappable row inside a [DsBottomSheet] action menu: a rounded square
/// icon tile, a label (with optional subtitle) and an optional chevron. Set
/// [isDestructive] to render it in the danger colour.
class DsSheetAction extends StatelessWidget {
  const DsSheetAction({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    this.showChevron = false,
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showChevron;
  final Color? iconColor;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive
        ? AppColors.danger
        : (iconColor ?? AppColors.primary);
    final bg = isDestructive
        ? AppColors.danger.withValues(alpha: 0.10)
        : (iconBackground ?? AppColors.primarySoft);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDestructive
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (showChevron)
              const Icon(LucideIcons.chevronRight,
                  size: 20, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}
