import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const white50 = Color(0xFFFFFFFF);
  static const white100 = Color(0xFFFFFFFF);
  static const white200 = Color(0xFFFFFFFF);
  static const white300 = Color(0xFFFFFFFF);
  static const white400 = Color(0xFFFFFFFF);
  static const white500 = Color(0xFFFFFFFF);
  static const white600 = Color(0xFFE8E8E8);
  static const white700 = Color(0xFFB5B5B5);
  static const white800 = Color(0xFF8C8C8C);
  static const white900 = Color(0xFF6B6B6B);

  static const black50 = Color(0xFFE6E6E6);
  static const black100 = Color(0xFFb0b0b0);
  static const black200 = Color(0xFF8a8a8a);
  static const black300 = Color(0xFF545454);
  static const black400 = Color(0xFF333333);
  static const black500 = Color(0xFF000000);
  static const black600 = Color(0xFF000000);
  static const black700 = Color(0xFF000000);
  static const black800 = Color(0xFF000000);
  static const black900 = Color(0xFF000000);

  static const blue50 = Color(0xFFecf2f7);
  static const blue100 = Color(0xFFc3d8e6);
  static const blue200 = Color(0xFFa7c5da);
  static const blue300 = Color(0xFF7eaac9);
  static const blue400 = Color(0xFF6599be);
  static const blue500 = Color(0xFF3f80ae);
  static const blue600 = Color(0xFF39749e);
  static const blue700 = Color(0xFF2d5b7c);
  static const blue800 = Color(0xFF234660);
  static const blue900 = Color(0xFF1a3649);

  static const red = Color(0xFFCC0505);
  static const green = Color(0xFF228b22);
  static const blue = Color(0xFF9bddff);
  static const purple = Color(0xFFbf00ff);
  static const mediumBlue = Color(0xFF0000cd);

  static const Gradient gradientColors = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffB7E1FF), // A deeper gold
      Color(0xffFFFFFF), // Lighter gold that resembles the shiny effect
      // Color(0xffF8E4A0),
      // Color(0xff9E7A4D),
    ],
  );

  // ===========================================================================
  // 2026 Redesign tokens (from Figma "Design System")
  // Additive: do NOT remove the legacy tokens above — existing screens use them.
  // ===========================================================================

  // Brand / primary
  static const Color primary = Color(0xFF1F58D8); // Primary/80
  static const Color primaryDark = Color(0xFF1037B7); // Primary/Purple 80

  // Surfaces
  static const Color background = Color(0xFFF5F6F9); // app scaffold background
  static const Color surface = Color(0xFFFFFFFF); // cards, sheets
  static const Color stroke = Color(0xFFE9EBEF); // borders / dividers
  static const Color fill = Color(0xFFF3F3F3); // Black/5 — chips, inputs

  // Text (Black scale)
  static const Color textPrimary = Color(0xFF101214); // Black/100
  static const Color textSecondary = Color(0xFF40495C); // Black/80
  static const Color textMuted = Color(0xFF7C8598); // Black/60
  static const Color textFaint = Color(0xFFA0A8B9); // Black/40

  // Status
  static const Color success = Color(0xFF1E9E56); // Alert/Success 100
  static const Color warning = Color(0xFFDB881F); // Alert/Warning 100
  static const Color danger = Color(0xFFFB4958); // Alert/Error 100

  // Tracking pill (mini timer widget on the project-details bottom bar)
  static const Color trackingDot = Color(0xFF46FF97); // live green indicator
  static const Color trackingStopBg = Color(0x66FF6C73); // translucent red stop
  static const Color trackingPauseBg = Color(0xFFFFFFFF); // white pause/resume

  // Soft status backgrounds (chips/badges)
  static const Color successSoft = Color(0xFFE7F5EE);
  static const Color warningSoft = Color(0xFFFBF1E3);
  static const Color primarySoft = Color(0xFFEAF0FC);
  static const Color neutralSoft = Color(0xFFEFF1F5);

  // Gradient cards
  static const Gradient timerCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE9B98C), Color(0xFF6E86E0), Color(0xFF2F55D4)],
  );

  static const Gradient runningCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4F74E0), Color(0xFF2A4FD0)],
  );

  static const Gradient breakCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE98A8A), Color(0xFFD85A5A)],
  );
}
