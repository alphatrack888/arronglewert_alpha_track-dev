import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// White rounded surface used everywhere in the redesign (project rows, stat
/// cards, list tiles). Matches the Figma card: 16px radius, hairline stroke and
/// a very soft shadow.
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.radius = 16,
    this.color,
    this.border = true,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;
  final Color? color;
  final bool border;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: border
            ? Border.all(color: borderColor ?? AppColors.stroke)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null && onLongPress == null) return card;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress == null
          ? null
          : () {
              Feedback.forLongPress(context);
              onLongPress!();
            },
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
