import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color backgroundColor;
  final bool showLeading;
  final VoidCallback? onBackPressed;
  final String? actionIcon; 
  final VoidCallback? onActionPressed; 
  final bool showAction; 

  const AuthAppBar({
    super.key,
    this.title,
    this.backgroundColor = Colors.transparent,
    this.showLeading = true,
    this.onBackPressed,
    this.actionIcon, 
    this.onActionPressed, 
    this.showAction = false, 
  });

  @override
  Widget build(BuildContext context) {
    final textColor = backgroundColor == AppColors.white100
        ? AppColors.blue500
        : AppColors.white200;

    return AppBar(
      leading: showLeading
          ? IconButton(
              icon: SvgPicture.asset(
                AppIcons.appbarBackButton,
                width: 35,
                height: 35,
              ),
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null,
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: title != null
          ? AppText(
              text: title!,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.50,
            )
          : null,
      backgroundColor: backgroundColor,
      actions: [
        if (showAction && actionIcon != null) 
          IconButton(
            icon: SvgPicture.asset(
              actionIcon!,
              width: 35,
              height: 35,
            ),
            onPressed: onActionPressed, 
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}