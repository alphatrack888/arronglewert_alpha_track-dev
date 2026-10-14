import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Centralised typography for the 2026 redesign.
///
/// All styles use the app's bundled `Hanken Grotesk` family (see pubspec.yaml)
/// so they render identically across platforms and match the Figma design.
/// Use these instead of inlining `TextStyle(...)` so the type scale stays 1:1.
class AppTextStyles {
  AppTextStyles._();

  static const String _family = 'Hanken Grotesk';

  static const TextStyle _base = TextStyle(
    fontFamily: _family,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Big timer readout, e.g. "0h 0m" / "00:14:28".
  static TextStyle timer = _base.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  /// Screen titles ("Projects", "Notifications").
  static TextStyle headline = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// Section / card titles.
  static TextStyle title = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static TextStyle titleSmall = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Default body text.
  static TextStyle body = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodySemibold = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Muted secondary line under a title.
  static TextStyle subtitle = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  /// Small labels, captions, eyebrow text.
  static TextStyle caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// Section eyebrow ("TODAY", "RECENT PROJECTS").
  static TextStyle eyebrow = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.6,
  );

  /// Text that sits on the primary button / coloured surfaces.
  static TextStyle button = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.white50,
  );
}
