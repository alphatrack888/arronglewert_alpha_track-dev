import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Loading / error / empty / list for Time Tracker Recent sessions.
class TimeTrackerSessionsBody extends StatelessWidget {
  const TimeTrackerSessionsBody({
    super.key,
    required this.kind,
    required this.onRetry,
    required this.empty,
    required this.children,
  });

  final TimeTrackerListKind kind;
  final VoidCallback onRetry;
  final Widget empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case TimeTrackerListKind.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      case TimeTrackerListKind.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                const Icon(LucideIcons.circleAlert,
                    size: 36, color: AppColors.textFaint),
                const SizedBox(height: 12),
                Text('retry'.tr, style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'retry'.tr,
                  isTranslate: false,
                  onTap: onRetry,
                ),
              ],
            ),
          ),
        );
      case TimeTrackerListKind.empty:
        return empty;
      case TimeTrackerListKind.list:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
    }
  }
}
