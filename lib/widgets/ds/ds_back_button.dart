import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Pop the current route reliably.
///
/// `Get.back()` resolves the navigator through GetX's global key and *silently
/// does nothing* when that key's `currentState` is detached
/// (`global(id).currentState?.canPop() == true` is false when the state is
/// null). That is the failure mode behind the recurring "Back is not working"
/// reports — no crash, no feedback, just a dead button.
///
/// Popping through the widget's own `context` cannot desync from the navigator
/// that actually rendered the route. `Get.back()` is kept only as a fallback for
/// routes presented outside the local navigator (e.g. GetX overlays).
Future<void> dsPop(BuildContext context, {Object? result}) async {
  final navigator = Navigator.maybeOf(context);
  if (navigator != null && navigator.canPop()) {
    navigator.pop(result);
    return;
  }
  // No local route to pop (or no Navigator ancestor) — let GetX try.
  Get.back<Object?>(result: result);
}

/// Round icon button used in screen headers (back / bell / share / overflow).
///
/// `HitTestBehavior.opaque` makes the whole [size]x[size] box tappable rather
/// than just the glyph — circular buttons otherwise drop taps that land in the
/// transparent corners.
class DsCircleIconButton extends StatelessWidget {
  const DsCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.background = AppColors.surface,
    this.iconColor = AppColors.textPrimary,
    this.border,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color background;
  final Color iconColor;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

/// The standard header back arrow. Pops via [dsPop] so it can never be a no-op
/// while a route is on the stack.
class DsBackButton extends StatelessWidget {
  const DsBackButton({super.key, this.onPressed, this.size = 40});

  /// Override the default pop (e.g. to confirm unsaved changes first).
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DsCircleIconButton(
      icon: LucideIcons.arrowLeft,
      size: size,
      onTap: onPressed ?? () => dsPop(context),
    );
  }
}
