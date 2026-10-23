import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:flutter/material.dart';

/// Square colour-from-name avatar with initials (e.g. "SP", "OS").
class DsAvatar extends StatelessWidget {
  const DsAvatar(
      {super.key, required this.name, this.size = 44, this.circle = false});
  final String name;
  final double size;
  final bool circle;

  static const _palette = [
    Color(0xFF1B8A8F), // teal
    Color(0xFF7BA23F), // green
    Color(0xFF3F80AE), // blue
    Color(0xFFB5743F), // amber
    Color(0xFF8A5BB0), // purple
    Color(0xFFCC5C5C), // red
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
  }

  Color get _color =>
      _palette[name.isEmpty ? 0 : name.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.27),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.bodySemibold.copyWith(
            color: AppColors.white50, fontSize: size < 28 ? 11 : null),
      ),
    );
  }
}

/// Compact project row used on Home (recent) and the Projects list.
class DsProjectTile extends StatelessWidget {
  const DsProjectTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    this.trailingSub,
    this.onTap,
    this.onAction,
    this.actionIcon = Icons.play_arrow_rounded,
    this.actionMuted = false,
    this.selected = false,
    this.onLongPress,
  });

  final String title;
  final String subtitle;
  final String trailingText;
  final String? trailingSub;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final IconData actionIcon;

  /// Quiets the action color without changing its size or ignoring the tap.
  final bool actionMuted;

  /// Primary hairline and a light primary fill.
  final bool selected;

  /// Selects this project without opening details.
  final VoidCallback? onLongPress;

  static final Color selectedFill = Color.alphaBlend(
    AppColors.primary.withValues(alpha: 0.06),
    AppColors.surface,
  );

  @override
  Widget build(BuildContext context) {
    return DsCard(
      onTap: onTap,
      onLongPress: onLongPress,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      color: selected ? selectedFill : null,
      borderColor: selected ? AppColors.primary : null,
      child: Row(
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
                    style: AppTextStyles.bodySemibold),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(trailingText, style: AppTextStyles.bodySemibold),
              if (trailingSub != null) ...[
                const SizedBox(height: 2),
                Text(trailingSub!, style: AppTextStyles.caption),
              ],
            ],
          ),
          if (onAction != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: actionMuted ? AppColors.fill : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  actionIcon,
                  color: actionMuted ? AppColors.textFaint : AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
