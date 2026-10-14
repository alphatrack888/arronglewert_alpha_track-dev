import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_chip.dart';
import 'package:alpha_track/widgets/ds/ds_project_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Expanded "running project" card — Figma Card_Home_Project (running variant).
///
/// Avatar + title + company, Stop + Pause/Resume controls, Today / This week /
/// Billable stats, and status chips. Shown on Home (recent projects) and the
/// Projects list for the project that's currently being tracked.
class DsRunningProjectCard extends StatelessWidget {
  const DsRunningProjectCard({
    super.key,
    required this.title,
    required this.company,
    required this.today,
    required this.thisWeek,
    required this.billable,
    required this.paused,
    required this.onStop,
    required this.onToggle,
    this.overtime = 'Overtime',
    this.onTap,
  });

  final String title;
  final String company;
  final String today;
  final String thisWeek;
  final String billable;
  final bool paused; // running vs paused (controls the pause/resume glyph)
  final VoidCallback onStop;
  final VoidCallback onToggle;
  final String overtime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DsAvatar(name: title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _squareBtn(LucideIcons.square, AppColors.danger,
                  AppColors.danger.withValues(alpha: 0.12), onStop),
              const SizedBox(width: 10),
              _squareBtn(paused ? LucideIcons.play : LucideIcons.pause,
                  Colors.white, AppColors.primary, onToggle),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('today1'.tr, today),
              _vDivider(),
              _stat('thisWeek'.tr, thisWeek),
              _vDivider(),
              _stat('billable'.tr, billable),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsChip.primary('chipDefault'.tr),
              paused ? DsChip.neutral('chipPaused'.tr) : DsChip.success('chipRunning'.tr),
              DsChip.warning('overtime'.tr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _squareBtn(IconData icon, Color fg, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: fg, size: 20),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 32,
        color: AppColors.stroke,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );
}
