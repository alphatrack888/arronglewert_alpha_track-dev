import 'package:alpha_track/screens/bottom_navigation/controller/bottom_navigation_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  BottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavScreenController controller =
        Get.find<BottomNavScreenController>();
    return Scaffold(
      key: scaffoldKey,
      body: Obx(() => controller.pages[controller.selectedIndex.value]),
      bottomNavigationBar: _buildBottomNavBar(controller),
      backgroundColor: AppColors.background,
    );
  }

  Widget _buildBottomNavBar(BottomNavScreenController controller) {
    return Obx(() {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.stroke)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildNavBarItems(controller),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildNavBarItems(BottomNavScreenController controller) {
    final List<Map<String, String>> tabData = [
      {'icon': AppIcons.homeGray, 'text': 'home'.tr},
      {'icon': AppIcons.projectgray, 'text': 'projects'.tr},
      {'icon': AppIcons.profileGray, 'text': 'account'.tr},
    ];

    return tabData.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final isSelected = controller.selectedIndex.value == index;

      return CustomNavItem(
        icon: tab['icon']!,
        text: tab['text']!,
        isSelected: isSelected,
        onTap: () => controller.onItemTapped(index),
      );
    }).toList();
  }
}

class CustomNavItem extends StatelessWidget {
  final String icon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textFaint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
