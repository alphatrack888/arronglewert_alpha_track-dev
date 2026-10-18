import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:flutter/material.dart';

/// Shared auth-screen header for the 2026 redesign.
///
/// Presentation only: round white 40x40 back button ([DsBackButton] / [dsPop])
/// next to
/// a bold [title], with an optional muted [subtitle] below. Matches the Figma
/// auth frames (Log In, Create Account, Reset Password, OTP).
class DsAuthHeader extends StatelessWidget {
  const DsAuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const DsBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headline,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 24),
          Text(
            subtitle!,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
