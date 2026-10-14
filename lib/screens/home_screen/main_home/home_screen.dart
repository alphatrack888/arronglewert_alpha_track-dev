import 'dart:ui';
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/bottom_navigation/controller/bottom_navigation_screen_controller.dart';
import 'package:alpha_track/screens/profile_screen/profile_screen_main/controller/profile_controller.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:alpha_track/widgets/ds/ds_project_tile.dart';
import 'package:alpha_track/widgets/ds/ds_running_project_card.dart';
import 'package:alpha_track/widgets/ds/ds_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  final HomeScreenController controller = Get.find<HomeScreenController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProjectList();
      controller.initializeReportData();
    });
  }

  // ---- small formatting helpers (presentation only) -------------------------
  String _fmtHours(double? h) {
    final v = h ?? 0;
    final hh = v.floor();
    final mm = ((v - hh) * 60).round();
    return '${hh}h ${mm}m';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '${'goodMorning'.tr},';
    if (hour < 17) return '${'goodAfternoon'.tr},';
    return '${'goodEvening'.tr},';
  }

  String get _todayLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    controller.showOneMinuteDialog = () {
      showTimeContineuDialog(context);
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.loadProjectList();
            await controller.refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                Obx(() {
                  if (controller.isOnBreak) return _buildBreakView();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimerCard(),
                      const SizedBox(height: 16),
                      controller.isRunning
                          ? _buildSessionActions()
                          : _buildStatCards(),
                      const SizedBox(height: 24),
                      DsSectionHeader(
                        title: 'recentProjects'.tr,
                        actionLabel: 'seeAll'.tr,
                        isTranslate: false,
                        onAction: () =>
                            Get.find<BottomNavScreenController>()
                                .onItemTapped(1),
                      ),
                      const SizedBox(height: 12),
                      _buildRecentProjects(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- header ---------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      children: [
        // Profile avatar removed — it had no functionality behind it.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: AppTextStyles.subtitle),
              Obx(() {
                final name = profileController.fullName;
                return Text(
                  name.isNotEmpty ? name : 'greetingFallback'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                );
              }),
            ],
          ),
        ),
        _circleIconButton(
          child: SvgPicture.asset(AppIcons.notificationIcons, width: 20, height: 20),
          onTap: () => Get.toNamed(AppRoute.notificationScreen),
        ),
        const SizedBox(width: 10),
        _circleIconButton(
          child: const Icon(LucideIcons.barChart3,
              size: 20, color: AppColors.textSecondary),
          onTap: () => Get.toNamed(AppRoute.reportScreen),
        ),
      ],
    );
  }

  Widget _circleIconButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  // ---- timer card (idle / running) -----------------------------------------
  Widget _buildTimerCard() {
    final running = controller.isRunning;
    final today = controller.workingHoursSummary.value?.data?.today ?? 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: running
            ? AppColors.runningCardGradient
            : AppColors.timerCardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TODAY',
                  style: AppTextStyles.eyebrow.copyWith(
                      color: AppColors.white50.withValues(alpha: 0.85),
                      letterSpacing: 1)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white50.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.calendar,
                      size: 12, color: AppColors.white50.withValues(alpha: 0.9)),
                  const SizedBox(width: 6),
                  Text(_todayLabel,
                      style: AppTextStyles.caption.copyWith(color: AppColors.white50)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(_fmtHours(today),
              style: AppTextStyles.timer.copyWith(color: AppColors.white50)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('dailyGoal'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white50)),
              Text('${_fmtHours(today)} / 8h',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white50)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (today / 8).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.white50.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(AppColors.white50),
            ),
          ),
          const SizedBox(height: 16),
          running ? _runningProjectRow() : _startButton(),
        ],
      ),
    );
  }

  Widget _startButton() {
    return PrimaryButton(
      label: AppString.start,
      svgIcon: null,
      icon: LucideIcons.play,
      color: AppColors.white50.withValues(alpha: 0.22),
      textColor: AppColors.white50,
      onTap: () => controller.toggleStartReset(),
    );
  }

  Widget _runningProjectRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white50.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
                color: AppColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(controller.currentProjectTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySemibold.copyWith(color: AppColors.white50)),
          ),
          Obx(() => Text(controller.formattedTime,
              style: AppTextStyles.bodySemibold.copyWith(color: AppColors.white50))),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => controller.togglePauseResume(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.white50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(() => Icon(
                  controller.isPaused ? LucideIcons.play : LucideIcons.pause,
                  color: AppColors.primary, size: 22)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- session actions (running) -------------------------------------------
  Widget _buildSessionActions() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: 'takeABreak'.tr,
            isTranslate: false,
            icon: LucideIcons.coffee,
            color: AppColors.warning,
            onTap: () => controller.pause(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SecondaryButton(
            label: 'stopSession'.tr,
            isTranslate: false,
            icon: LucideIcons.square,
            color: AppColors.danger,
            onTap: () => controller.stop(),
          ),
        ),
      ],
    );
  }

  // Project row inside the ON BREAK card: status dot + project/company + resume.
  Widget _breakProjectRow() {
    final white = AppColors.white50;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Same 8x8 status dot as the running (blue) card's project pill —
          // previously this was a 10px dot inside a 36px halo, so the two
          // cards' "dot" items looked nothing alike.
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.currentProjectTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppTextStyles.bodySemibold.copyWith(color: white)),
                const SizedBox(height: 2),
                Text(controller.currentProjectCompany,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => controller.resume(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.play, color: white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ---- break view (on break) ------------------------------------------------
  Widget _buildBreakView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ON BREAK card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.breakCardGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('onBreak'.tr,
                      style: AppTextStyles.eyebrow.copyWith(
                          color: AppColors.white50.withValues(alpha: 0.9),
                          letterSpacing: 1)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.white50.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.breakStartedLabel,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.white50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Obx(() => Text(controller.formattedBreakTime,
                  style: AppTextStyles.timer.copyWith(color: AppColors.white50))),
              const SizedBox(height: 18),
              _breakProjectRow(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Break reminder (hidden once snoozed via 'remindIn15'.tr)
        Obx(() => controller.reminderVisible.value
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('breakReminder'.tr, style: AppTextStyles.eyebrow),
                  const SizedBox(height: 12),
                  DsCard(
                    color: AppColors.warningSoft,
                    border: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.triangleAlert,
                              size: 18, color: AppColors.white50),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'onBreakFor'.trParams({'min': '${controller.breakMinutes}'}),
                                  style: AppTextStyles.bodySemibold),
                              const SizedBox(height: 2),
                              Text('comeBackToWork'.tr,
                                  style: AppTextStyles.subtitle),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: SecondaryButton(
                                      label: 'remindIn15'.tr,
                                      isTranslate: false,
                                      height: 38,
                                      color: AppColors.warning,
                                      onTap: () => controller.snoozeReminder(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  PrimaryButton(
                                    label: 'Dismiss',
                                    isTranslate: false,
                                    width: 100,
                                    height: 38,
                                    color: AppColors.danger,
                                    onTap: () => controller.resume(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            : const SizedBox.shrink()),
        Text('todaysBreaks'.tr, style: AppTextStyles.eyebrow),
        const SizedBox(height: 12),
        Obx(() => _breakItem(AppColors.danger, 'currentBreak'.tr, 'inProgress'.tr,
            controller.formattedBreakTime)),
        _breakItem(const Color(0xFFE9856B), 'Lunch', '12:30 – 13:05', '35m'),
        _breakItem(const Color(0xFFE9B98C), 'Coffee', '10:15 – 10:23', '8m'),
      ],
    );
  }

  Widget _breakItem(Color dot, String title, String subtitle, String trailing) {
    return DsCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: dot.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(LucideIcons.coffee, size: 15, color: dot),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemibold),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(trailing, style: AppTextStyles.bodySemibold),
        ],
      ),
    );
  }

  // ---- stat cards (idle) ----------------------------------------------------
  Widget _buildStatCards() {
    return Obx(() {
      final s = controller.workingHoursSummary.value?.data;
      final week = s?.thisWeek ?? 0.0;
      final month = s?.thisMonth ?? 0.0;
      return Row(
        children: [
          _statCard('thisWeek'.tr, _fmtHours(week)),
          const SizedBox(width: 12),
          _statCard('thisMonth'.tr, _fmtHours(month)),
          const SizedBox(width: 12),
          _statCard('avgPerDay'.tr, _fmtHours(week / 7)),
        ],
      );
    });
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: DsCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall),
          ],
        ),
      ),
    );
  }

  // ---- recent projects ------------------------------------------------------
  Widget _buildRecentProjects() {
    return Obx(() {
      if (controller.isProjectLoading) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: LoadingAnimationWidget.beat(
                size: 40, color: AppColors.primary),
          ),
        );
      }
      final projects = controller.allProjectData.value?.data?.data;
      if (projects == null || projects.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('noProjectsAvailable'.tr, style: AppTextStyles.subtitle),
          ),
        );
      }
      return Column(
        children: projects.map((project) {
          final title = project.title ?? 'untitledProject'.tr;
          final company = project.company?.name ?? 'Active';
          final isThis = controller.currentProjectId == (project.id ?? '');
          final running = isThis && controller.isRunning;
          final paused = isThis && controller.isPaused;
          // The project being tracked shows the expanded running card.
          if (running || paused) {
            return DsRunningProjectCard(
              title: title,
              company: company,
              today: _fmtMins(project.projectTime),
              thisWeek: _fmtMins(project.duration),
              billable: '\$0',
              paused: paused,
              onStop: () => controller.stop(),
              onToggle: () => controller.togglePauseResume(),
              onTap: () {
                controller.setCurrentProjectId(project.id ?? '',
                    projectTitle: title);
                controller.gototheDetailsPage();
              },
            );
          }
          return DsProjectTile(
            title: title,
            subtitle: company,
            trailingText: '${project.projectTime ?? 0}h',
            trailingSub: 'today1'.tr,
            onTap: () {
              controller.setCurrentProjectId(project.id ?? '',
                  projectTitle: title);
              controller.gototheDetailsPage();
            },
            onAction: () {
              controller.setCurrentProjectId(project.id ?? '',
                  projectTitle: title);
              controller.toggleStartReset();
            },
          );
        }).toList(),
      );
    });
  }

  String _fmtMins(int? m) =>
      (m == null || m <= 0) ? '0h 0m' : '${m ~/ 60}h ${m % 60}m';

  // ---------------------------------------------------------------------------
  // Hourly "continue or break" dialog — wiring preserved from the original.
  // ---------------------------------------------------------------------------
  void showTimeContineuDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DsDialog(
          title: 'timeForBreakQ'.tr,
          tone: DsDialogTone.info,
          icon: LucideIcons.clock,
          barrierDismissible: false,
          cancelLabel: 'Break',
          confirmLabel: 'Continue',
          onCancel: () {
            controller.onBreakPressed();
          },
          onConfirm: () async {
            await controller.onContinuePressed();
          },
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return controller.isLocationLoading
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            LoadingAnimationWidget.beat(
                                size: 40, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text('updatingLocation'.tr,
                                style: AppTextStyles.caption),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              Obx(() {
                final hours =
                    (controller.elapsed.inMilliseconds / 3600000).floor();
                return Text(
                  'workingForHours'.trParams({'hours': '$hours ${hours > 1 ? 'hourPlural'.tr : 'hourSingular'.tr}'}),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle.copyWith(height: 1.45),
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.formattedLocation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
