import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';

/// Shared empty / error placeholder for the 2026 redesign: a soft circular icon
/// badge, a title, a muted message and an optional action button. Use it for
/// empty lists ("No notes yet") and for error / retry states ("Couldn't load —
/// Try again") so every screen handles the no-content case the same way.
class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Renders the icon badge in the danger tone for error states.
  final bool isError;

  /// Tighter spacing for use inside cards / small regions.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = isError ? AppColors.danger : AppColors.primary;
    final badgeBg = isError
        ? AppColors.danger.withValues(alpha: 0.10)
        : AppColors.primarySoft;
    final badgeSize = compact ? 64.0 : 88.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: compact ? 16 : 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
              child: Icon(icon, size: compact ? 28 : 38, color: accent),
            ),
            SizedBox(height: compact ? 14 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(height: 1.45),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 16 : 24),
              SizedBox(
                width: 200,
                child: PrimaryButton(label: actionLabel!, onTap: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
