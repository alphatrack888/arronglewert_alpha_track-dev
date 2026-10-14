import 'dart:ui';

import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Visual intent of a [DsDialog] — drives the icon-badge colour.
enum DsDialogTone { info, success, warning, danger }

/// The single source of truth for modals/confirmations/warnings in the 2026
/// redesign. Presents a centred white card (16px radius, soft shadow) over a
/// blurred scrim, with an optional coloured icon badge, title, message and one
/// or two pill buttons (re-using [PrimaryButton] / [SecondaryButton]).
///
/// Presentation only — callers pass the wired actions; no business logic here.
///
/// Use the helpers below instead of building dialogs inline:
/// * [DsDialog.confirm] — yes/no confirmation, returns `true` when confirmed.
/// * [DsDialog.alert]   — single-button acknowledgement.
class DsDialog extends StatelessWidget {
  const DsDialog({
    super.key,
    required this.title,
    this.message,
    this.tone = DsDialogTone.info,
    this.icon,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.confirmIsDestructive = false,
    this.content,
    this.barrierDismissible = true,
  });

  final String title;
  final String? message;
  final DsDialogTone tone;
  final IconData? icon;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool confirmIsDestructive;

  /// Optional custom body placed between the message and the buttons.
  final Widget? content;
  final bool barrierDismissible;

  Color get _toneColor {
    switch (tone) {
      case DsDialogTone.success:
        return AppColors.success;
      case DsDialogTone.warning:
        return AppColors.warning;
      case DsDialogTone.danger:
        return AppColors.danger;
      case DsDialogTone.info:
        return AppColors.primary;
    }
  }

  Color get _toneSoft {
    switch (tone) {
      case DsDialogTone.success:
        return AppColors.successSoft;
      case DsDialogTone.warning:
        return AppColors.warningSoft;
      case DsDialogTone.danger:
        return AppColors.danger.withValues(alpha: 0.10);
      case DsDialogTone.info:
        return AppColors.primarySoft;
    }
  }

  IconData get _defaultIcon {
    switch (tone) {
      case DsDialogTone.success:
        return LucideIcons.check;
      case DsDialogTone.warning:
        return LucideIcons.triangleAlert;
      case DsDialogTone.danger:
        return LucideIcons.triangleAlert;
      case DsDialogTone.info:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? _defaultIcon;
    final destructive = confirmIsDestructive || tone == DsDialogTone.danger;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          // Cap the height and let the body scroll, so a long [message] or
          // [content] can never push the buttons off-screen (where they'd be
          // clipped and untappable). The button Row stays pinned below the
          // scroll area and is therefore always laid out within bounds.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _toneSoft,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(effectiveIcon, color: _toneColor, size: 28),
                        ),
                        const SizedBox(height: 16),
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
                        if (content != null) ...[
                          const SizedBox(height: 16),
                          content!,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (cancelLabel != null) ...[
                      Expanded(
                        child: SecondaryButton(
                          label: cancelLabel!,
                          // Close via the dialog's own context (reliable) then
                          // run the caller's side effect. Callers must NOT pop
                          // themselves. Returns false to DsDialog.confirm().
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop(false);
                            }
                            onCancel?.call();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: PrimaryButton(
                        label: confirmLabel ?? 'OK',
                        color: destructive ? AppColors.danger : null,
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop(true);
                          }
                          onConfirm?.call();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirmation dialog. Resolves to `true` when the user confirms, `false`
  /// (or `null`) otherwise. Defaults to a destructive (danger) treatment so it
  /// reads as a warning; pass [tone] to soften it.
  static Future<bool> confirm({
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    DsDialogTone tone = DsDialogTone.danger,
    IconData? icon,
    bool destructive = true,
  }) async {
    final result = await Get.dialog<bool>(
      DsDialog(
        title: title,
        message: message,
        tone: tone,
        icon: icon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmIsDestructive: destructive,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.25),
    );
    return result ?? false;
  }

  /// Single-button acknowledgement (errors, info, success).
  static Future<void> alert({
    required String title,
    String? message,
    String confirmLabel = 'OK',
    DsDialogTone tone = DsDialogTone.info,
    IconData? icon,
    VoidCallback? onConfirm,
  }) {
    return Get.dialog<void>(
      DsDialog(
        title: title,
        message: message,
        tone: tone,
        icon: icon,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.25),
    );
  }
}
