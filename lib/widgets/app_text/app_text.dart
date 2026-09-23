import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.fontSize,
    this.textScaleFactor = 0.9,
    this.color = Colors.black,
    this.fontWeight = FontWeight.w400,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.center,
    this.height,
    this.decoration,
    this.decorationColor,
    this.left = 0,
    this.right = 0,
    this.top = 0,
    this.bottom = 0,
    this.isTranslate = true, // Default to translate
  });

  final bool isTranslate;
  final double left;
  final double right;
  final double top;
  final double bottom;
  final double? fontSize;
  final double textScaleFactor;
  final Color? color;
  final FontWeight? fontWeight;
  final String text;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final double? height;
  final TextDecoration? decoration;
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      ),
      child: Text(
        isTranslate ? text.tr : text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: const TextStyle(fontFamily: 'Roboto', height: 1.5).copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          decoration: decoration ?? TextDecoration.none,
          decorationColor: decorationColor,
        ),
      ),
    );
  }
}
