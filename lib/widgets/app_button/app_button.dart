import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.height,
    this.width,
    this.alignment,
    this.child,
    this.decoration,
    this.onTap,
    this.padding,
    this.title,
    this.isLoading = false,
    this.loaderColor,
    this.margin,
    this.backgroundColor,
    this.loadingSize,
    this.titleColor,
    this.border,
    this.borderColor,
    this.borderradius,
    this.isBorder = false,
    this.fontSize,
  });

  final double? loadingSize;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;
  final Widget? child;
  final String? title;
  final void Function()? onTap;
  final bool isLoading;
  final Color? titleColor;
  final Color? loaderColor;
  final Color? backgroundColor;
  final BoxBorder? border;
  final Color? borderColor;
  final double? borderradius;
  final bool isBorder;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: Durations.long1,
        curve: Curves.ease,
        width: width,
        height: height ?? 48,
        alignment: alignment ?? Alignment.center,
        margin: margin,
        padding: padding ?? EdgeInsets.all(AppSize.width(value: 5.0)),
        decoration:
            decoration ??
            BoxDecoration(
              color: backgroundColor ?? AppColors.white50,
              border: isBorder
                  ? Border.all(color: AppColors.blue500, width: 5)
                  : borderColor != null
                  ? Border.all(color: borderColor!)
                  : null,
              borderRadius: BorderRadius.circular(
                borderradius ??
                    AppSize.width(value: 30.0),
              ),
            ),
        child: isLoading
            ? SizedBox(
                width: loadingSize ?? Get.height * 0.04,
                height: loadingSize ?? Get.height * 0.04,
                child: LoadingAnimationWidget.waveDots(
                  color: AppColors.white100,
                  size: loadingSize ?? Get.height * 0.04,
                ),
              )
            : child ??
                  AppText(
                    text: title ?? "",
                    fontSize: fontSize ?? AppSize.width(value: 14),
                    color: titleColor ?? AppColors.white50,
                    fontWeight: FontWeight.w700,
                  ),
      ),
    );
  }
}
