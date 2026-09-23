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
}
