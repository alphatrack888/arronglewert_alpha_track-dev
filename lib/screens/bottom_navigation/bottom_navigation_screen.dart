import 'package:alpha_track/screens/bottom_navigation/controller/bottom_navigation_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_icons/app_icons.dart';
import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_text/app_text.dart';
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
      backgroundColor: AppColors.white200,
    );
  }

  Widget _buildBottomNavBar(BottomNavScreenController controller) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.blue500,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
    final List<Map<String, dynamic>> tabData = [
      {
        'greenIcon': AppIcons.homeGray,
        'whiteIcon': AppIcons.homeWhite,
        'text': 'home'.tr,
      },
      {
        'greenIcon': AppIcons.breakGray,
        'whiteIcon': AppIcons.breakWhite,
        'text': 'leave'.tr,
      },
      {
        'greenIcon': AppIcons.noteGray,
        'whiteIcon': AppIcons.noteWhite,
        'text': 'notes'.tr,
      },
      {
        'greenIcon': AppIcons.profileGray,
        'whiteIcon': AppIcons.profileWhite,
        'text': 'profiles'.tr,
      },
    ];

    return tabData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> tab = entry.value;
      bool isSelected = controller.selectedIndex.value == index;

      return CustomNavItem(
        greenIcon: tab['greenIcon'],
        whiteIcon: tab['whiteIcon'],
        text: tab['text'],
        isSelected: isSelected,
        onTap: () => controller.onItemTapped(index),
      );
    }).toList();
  }
}

class CustomNavItem extends StatelessWidget {
  final String greenIcon;
  final String whiteIcon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavItem({
    super.key,
    required this.greenIcon,
    required this.whiteIcon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        // decoration: BoxDecoration(
        //   color: isSelected ? AppColors.blue200 : Colors.transparent,
        //   borderRadius: BorderRadius.circular(10),
        // ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? whiteIcon : greenIcon,
              width: AppSize.width(value: 25),
              height: AppSize.height(value: 25),
            ),
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  text: text,
                  color: isSelected ? AppColors.white200 : AppColors.white600,
                  fontSize: AppSize.width(value: 12),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.5,
                ),
                // Text(
                //   text,
                //   style: TextStyle(
                //     color: isSelected ? Colors.white : AppColors.white600,
                //     fontSize: 12,
                //   ),
                // ),
              ),
          ],
        ),
      ),
    );
  }
}
