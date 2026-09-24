import 'dart:ui';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/notification_screen/controller/notification_screen_controller.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/widgets/app_images/app_images.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_icons/app_icons.dart';
import '../../../utils/app_size/app_gap.dart';
import '../../../utils/app_size/app_size.dart';
import '../../../utils/app_string/app_string.dart';
import '../../../widgets/app_button/app_button.dart';
import '../../../widgets/app_text/app_text.dart';
import 'controller/home_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use Get.find to get the existing controller instance
  final HomeScreenController controller = Get.find<HomeScreenController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // Load projects when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectList();
    });
  }

  void showTimeContineuDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.white100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location update indicator
                  Obx(() {
                    return controller.isLocationLoading
                        ? Column(
                            children: [
                              LoadingAnimationWidget.beat(
                                size: 50,
                                color: AppColors.blue500,
                              ),
                              Gap(height: AppSize.height(value: 10)),
                              AppText(
                                text: 'Updating location...',
                                fontSize: 14,
                                color: AppColors.black400,
                              ),
                              Gap(height: AppSize.height(value: 10)),
                            ],
                          )
                        : SizedBox.shrink();
                  }),

                  Gap(height: AppSize.height(value: 20)),
                  Obx(() {
                    int hours = (controller.elapsed.inMilliseconds / 3600000)
                        .floor();
                    return AppText(
                      text:
                          'You have been working for $hours hour${hours > 1 ? 's' : ''}. Do you want to continue or take a break?',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black500,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    );
                  }),
                  Gap(height: AppSize.height(value: 20)),

                  // Show current location (optional)
                  Obx(() {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.blue500,
                          ),
                          Gap(width: AppSize.width(value: 8)),
                          Expanded(
                            child: AppText(
                              text: controller.formattedLocation,
                              fontSize: 12,
                              color: AppColors.black400,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  Gap(height: AppSize.height(value: 20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AppButton(
                        height: AppSize.height(value: 48),
                        width: AppSize.width(value: 100),
                        title: "Break",
                        titleColor: AppColors.red,
                        borderColor: AppColors.red,
                        backgroundColor: AppColors.white100,
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.onBreakPressed();
                        },
                      ),
                      AppButton(
                        height: AppSize.height(value: 48),
                        width: AppSize.width(value: 100),
                        title: "Continue",
                        titleColor: AppColors.white100,
                        backgroundColor: AppColors.blue500,
                        onTap: () async {
                          Navigator.of(context).pop();
                          await controller.onContinuePressed();
                        },
                      ),
                    ],
                  ),
                  Gap(height: AppSize.height(value: 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTodayContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            height: AppSize.height(value: 220),
            width: AppSize.width(value: 220),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => AppText(
                    text: controller.formattedTime,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black500,
                  ),
                ),
                Gap(height: AppSize.height(value: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => AppButton(
                        height: AppSize.height(value: 48),
                        width: AppSize.width(value: 95),
                        fontSize: AppSize.width(value: 13),
                        title:
                            controller.isRunning ||
                                controller.elapsed.inSeconds > 0
                            ? "Reset"
                            : AppString.start.tr,
                        titleColor: AppColors.white200,
                        backgroundColor:
                            controller.isRunning ||
                                controller.elapsed.inSeconds > 0
                            ? AppColors.red
                            : AppColors.blue500,
                        onTap: () {
                          controller.toggleStartReset();
                        },
                      ),
                    ),
                    Gap(width: AppSize.width(value: 10)),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          controller.togglePauseResume();
                        },
                        child: Container(
                          height: AppSize.height(value: 50),
                          width: AppSize.width(value: 50),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: controller.isPaused
                                ? SvgPicture.asset(AppIcons.resumeIcons)
                                : SvgPicture.asset(AppIcons.pauseIcon),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Gap(height: AppSize.height(value: 23)),
        AppText(
          text: AppString.myallProject.tr,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black500,
        ),
        Gap(height: AppSize.height(value: 10)),

        // Fixed project list implementation
        Obx(() {
          if (controller.isProjectLoading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: LoadingAnimationWidget.beat(
                  size: 50,
                  color: AppColors.blue500,
                ),
              ),
            );
          }

          final projects = controller.allProjectData.value?.data?.data;

          if (projects == null || projects.isEmpty) {
            return Container(
              padding: EdgeInsets.all(20),
              child: AppText(
                text: 'No projects available',
                fontSize: 16,
                color: AppColors.black400,
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: projects.map((project) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.setCurrentProjectId(
                        project.id ?? '',
                        projectTitle: project.title ?? 'Untitled Project',
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: controller.isProjectSelected(project.id ?? '')
                              ? AppColors.blue500
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.projectgray,
                                height: AppSize.height(value: 20),
                                width: AppSize.width(value: 20),
                              ),
                              Gap(width: AppSize.width(value: 10)),
                              AppText(
                                text: project.title ?? 'Untitled Project',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black400,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Gap(height: 5),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.clockGray,
                                height: AppSize.height(value: 20),
                                width: AppSize.width(value: 20),
                              ),
                              Gap(width: AppSize.width(value: 10)),
                              AppText(
                                text: '${project.projectTime ?? 0} hours',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black400,
                              ),
                              Spacer(),
                              AppButton(
                                title: "Details",
                                backgroundColor: AppColors.blue500,
                                titleColor: AppColors.white100,
                                width: AppSize.width(value: 100),
                                height: AppSize.height(value: 40),
                                onTap: () => controller.gototheDetailsPage(),
                              ),
                            ],
                          ),
                          if (project.company?.name != null) ...[
                            Gap(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 20,
                                  color: AppColors.black400,
                                ),
                                Gap(width: AppSize.width(value: 10)),
                                AppText(
                                  text: project.company!.name!,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black400,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  Gap(height: AppSize.height(value: 10)),
                ],
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget buildReportContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SyncFusion DatePicker
        Container(
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                blurRadius: 5.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.single,
            view: DateRangePickerView.month,
            startRangeSelectionColor: AppColors.black500,
            endRangeSelectionColor: AppColors.black500,
            rangeSelectionColor: AppColors.white800,
            backgroundColor: Colors.transparent,
            selectionShape: DateRangePickerSelectionShape.rectangle,
            headerStyle: const DateRangePickerHeaderStyle(
              backgroundColor: AppColors.white100,
              textStyle: TextStyle(
                color: AppColors.black500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value != null) {
                controller.updateSelectedDate(args.value);
              }
            },
          ),
        ),

        Gap(height: AppSize.height(value: 25)),

        // Loading indicator for report data
        Obx(() {
          if (controller.reportLoadingState.value == LoadingState.loading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: LoadingAnimationWidget.beat(
                  size: 50,
                  color: AppColors.blue500,
                ),
              ),
            );
          }
          return SizedBox.shrink();
        }),

        AppText(
          text: AppString.totalHours.tr,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black500,
          height: 1.5,
        ),
        Gap(height: AppSize.height(value: 5)),
        LayoutBuilder(
          builder: (context, constraints) {
            // Ensure the Row respects the parent's width
            final availableWidth = constraints.maxWidth;
            final containerWidth =
                (availableWidth - AppSize.width(value: 10)) / 2; // Subtract gap
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  width: containerWidth, // Use calculated width
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: AppString.today.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black400,
                        height: 1.5,
                      ),
                      SizedBox(height: 8), // Replace Spacer with fixed height
                      Obx(() {
                        final todayHours =
                            controller.workingHoursSummary.value?.data?.today ??
                            0.0;
                        return AppText(
                          text: '${todayHours.toStringAsFixed(1)}h',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black600,
                          height: 1.5,
                        );
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  width: containerWidth, 
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: AppString.thisWeek.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black400,
                        height: 1.5,
                      ),
                      SizedBox(height: 8), 
                      Obx(() {
                        final weekHours =
                            controller
                                .workingHoursSummary
                                .value
                                ?.data
                                ?.thisWeek ??
                            0.0;
                        return AppText(
                          text: '${weekHours.toStringAsFixed(1)}h',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black600,
                          height: 1.5,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        Gap(height: AppSize.height(value: 10)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: AppString.thisMonth.tr,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
                height: 1.5,
              ),
              SizedBox(height: 8), 
              Obx(() {
                final monthHours =
                    controller.workingHoursSummary.value?.data?.thisMonth ??
                    0.0;
                return AppText(
                  text: '${monthHours.toStringAsFixed(1)}h',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black600,
                  height: 1.5,
                );
              }),
            ],
          ),
        ),
        Gap(height: AppSize.height(value: 20)),
        AppText(
          text: AppString.breakhours.tr,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black500,
          height: 1.5,
        ),
        Gap(height: AppSize.height(value: 10)),
        Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(130),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Obx(() {
            final chartData = controller.getBarChartData();
            final maxValue = chartData.reduce((a, b) => a > b ? a : b);
            final chartMaxY = maxValue > 0 ? (maxValue + 1).ceilToDouble() : 6;

            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: chartMaxY.toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String weekDay;
                      switch (group.x.toInt()) {
                        case 0:
                          weekDay = 'Saturday'.tr;
                          break;
                        case 1:
                          weekDay = 'Sunday'.tr;
                          break;
                        case 2:
                          weekDay = 'Monday'.tr;
                          break;
                        case 3:
                          weekDay = 'Tuesday'.tr;
                          break;
                        case 4:
                          weekDay = 'Wednesday'.tr;
                          break;
                        case 5:
                          weekDay = 'Thursday'.tr;
                          break;
                        case 6:
                          weekDay = 'Friday'.tr;    
                          break;
                        default:
                          weekDay = '';
                      }
                      return BarTooltipItem(
                        '$weekDay\n${rod.toY.toStringAsFixed(1)}h',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Sat'.tr;
                            break;
                          case 1:
                            text = 'Sun'.tr;
                            break;
                          case 2:
                            text = 'Mon'.tr;
                            break;
                          case 3:
                            text = 'Tue'.tr;
                            break;
                          case 4:
                            text = 'Wed'.tr;
                            break;
                          case 5:
                            text = 'Thu'.tr;
                            break;
                          case 6:
                            text = 'Fri'.tr;  
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return SideTitleWidget(
                          space: 4,
                          meta: meta,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) return Container();
                        return SideTitleWidget(
                          space: 4,
                          meta: meta,
                          child: Text(
                            '${value.toInt()}h',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [3, 3],
                    );
                  },
                ),
                barGroups: List.generate(7, (index) {
                  final value = chartData[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: value > 0
                            ? AppColors.blue500
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMaxY.toDouble(),
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          }),
        ),
        Gap(height: AppSize.height(value: 40)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.showOneMinuteDialog = () {
      showTimeContineuDialog(context);
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: AppColors.white200,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Obx(
              () => AppImage(
                width: 40,
                height: 40,
                url: profileController.profileData.value?.data?.profile,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: AppString.hello.tr,
              fontSize: AppSize.width(value: 18),
              fontWeight: FontWeight.w500,
              color: AppColors.black500,
            ),
            Obx(
              () => AppText(
                text: profileController.fullName.tr,
                fontSize: AppSize.width(value: 15),
                fontWeight: FontWeight.w500,
                color: AppColors.black500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: EdgeInsets.all(08),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue50,
              ),
              child: IconButton(
                onPressed: () {
                  Get.toNamed(AppRoute.notificationScreen);
                },
                icon: Obx(() {
                  // NotificationScreenController is registered with
                  // fenix:true in InitialBinding, so Get.find here either
                  // reuses the existing instance (if the user has already
                  // opened the notification screen this session) or
                  // creates it fresh — either way this always reflects the
                  // real unread count, not just while that screen is open.
                  final unread = Get.find<NotificationScreenController>().unreadCount.value;
                  return Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread > 9 ? '9+' : '$unread'),
                    child: SvgPicture.asset(
                      AppIcons.notificationIcons,
                      width: 24,
                      height: 24,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white200,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(height: AppSize.height(value: 25)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Spacer(),
                Obx(
                  () => AppButton(
                    height: AppSize.height(value: 35),
                    width: AppSize.width(value: 82),
                    fontSize: AppSize.width(value: 12),
                    title: AppString.today.tr,
                    titleColor: controller.isTodaySelected.value
                        ? AppColors.white200
                        : AppColors.blue500,
                    backgroundColor: controller.isTodaySelected.value
                        ? AppColors.blue500
                        : AppColors.white200,
                    borderColor: controller.isTodaySelected.value
                        ? AppColors.blue500
                        : AppColors.blue500,
                    onTap: () => controller.selectToday(),
                  ),
                ),
                Gap(width: AppSize.width(value: 10)),
                Obx(
                  () => AppButton(
                    height: AppSize.height(value: 35),
                    width: AppSize.width(value: 82),
                    // Was labeled "Report" — confusing alongside the real
                    // generated PDF reports added under Profile > Reports
                    // (Phase 13), since this toggle only ever shows
                    // working-hours/break-hours charts.
                    title: AppString.overview.tr,
                    fontSize: AppSize.width(value: 12),
                    titleColor: controller.isTodaySelected.value
                        ? AppColors.blue500
                        : AppColors.white200,
                    backgroundColor: controller.isTodaySelected.value
                        ? AppColors.white200
                        : AppColors.blue500,
                    borderColor: controller.isTodaySelected.value
                        ? AppColors.blue500
                        : AppColors.blue500,
                    onTap: () {
                      controller.selectReport();
                    },
                  ),
                ),
              ],
            ),
            Gap(height: AppSize.height(value: 25)),
            // Wrap content inside Obx to reactively rebuild when isTodaySelected changes
            Obx(() {
              if (controller.isTodaySelected.value) {
                return buildTodayContent();
              } else {
                return buildReportContent();
              }
            }),
          ],
        ),
      ),
    );
  }
}
