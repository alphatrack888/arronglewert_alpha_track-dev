import 'package:alpha_track/utils/app_size/app_gap.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppButtonWithIcon extends StatelessWidget {
  final double? height;
  final String buttonText;
  final String svgIconPath;
  final Color textColor;
  final VoidCallback? onPressed;

  const AppButtonWithIcon({
    super.key,
    this.height,
    required this.buttonText,
    required this.svgIconPath,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x4C9A9090),
              blurRadius: 6,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(svgIconPath, width: 24, height: 24),
            Gap(width: AppSize.width(value: 10)),
            AppText(
              text: buttonText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
