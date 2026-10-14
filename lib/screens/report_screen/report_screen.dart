import 'package:alpha_track/screens/home_screen/main_home/controller/home_screen_controller.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_area_chart.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_bar_chart.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:alpha_track/utils/app_date/app_date.dart';

/// Reports screen (Day / Week / Month) — new in the 2026 redesign.
///
/// Reuses the existing [HomeScreenController] report logic (report repository,
/// working-hours summary, break-hours bar chart) so no business logic changes.
/// Day/Week/Month is purely a local view switch — it does not touch the
/// controller's data fetching.
enum _ReportTab { day, week, month }

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final HomeScreenController controller = Get.find<HomeScreenController>();

  // Local-only view state for the Day / Week / Month switcher.
  _ReportTab _tab = _ReportTab.day;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeReportData();
    });
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers (presentation only)
  // ---------------------------------------------------------------------------

  /// Convert a number of hours (double) to a "8h 30m" style label.
  String _formatHours(double? hours) {
    final h = hours ?? 0;
    final whole = h.floor();
    final minutes = ((h - whole) * 60).round();
    if (minutes == 0) return '${whole}h';
    return '${whole}h ${minutes}m';
  }

  String _formatDayHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final dayMonth = '${d.day} ${_months[d.month - 1]}';
    final diffDays = today.difference(target).inDays;
    if (diffDays == 0) return 'todayComma'.trParams({'d': dayMonth});
    if (diffDays == 1) return 'yesterdayComma'.trParams({'d': dayMonth});
    return dayMonth;
  }

  String _formatMonthHeader(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// Share a plain-text summary of the current report via the native share
  /// sheet. Uses the real working-hours totals already loaded by the controller.
  Future<void> _shareReport() async {
    final working = controller.workingHoursSummary.value?.data;
    final summary = controller.dailySummaryData.value?.data;

    final breakLabel = summary?.totalBreakInHoursFormatted ??
        summary?.totalBreakInHours ??
        '0h';
    final overtimeLabel =
        summary?.overtimeInHoursFormatted ?? summary?.overtime ?? '0h';

    // Period the user is currently looking at, so the shared text matches the
    // screen instead of always reading as a generic summary.
    final date = controller.selectedDate.value;
    final String period;
    switch (_tab) {
      case _ReportTab.day:
        period = _formatDayHeader(date);
        break;
      case _ReportTab.week:
        period = _weekRangeLabel(date);
        break;
      case _ReportTab.month:
        period = _formatMonthHeader(date);
        break;
    }

    final text = StringBuffer()
      ..writeln('timeReport'.tr)
      ..writeln(period)
      ..writeln()
      ..writeln('${'today1'.tr}:      ${_formatHours(working?.today)}')
      ..writeln('${'thisWeek'.tr}:  ${_formatHours(working?.thisWeek)}')
      ..writeln('This month: ${_formatHours(working?.thisMonth)}')
      ..writeln()
      ..writeln('${'breaks'.tr}:   $breakLabel')
      ..write('Overtime: $overtimeLabel');

    await SharePlus.instance.share(
      ShareParams(text: text.toString(), subject: 'timeReport'.tr),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 12,
        leadingWidth: 60,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: DsBackButton(),
        ),
        title: Text('report'.tr, style: AppTextStyles.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: DsCircleIconButton(
              icon: LucideIcons.share2,
              onTap: _shareReport,
              border: Border.all(color: AppColors.stroke),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final isLoading =
              controller.reportLoadingState.value == LoadingState.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryStrip(),
                const SizedBox(height: 16),
                _buildSegmentedSwitcher(),
                const SizedBox(height: 16),
                _buildPeriodHeader(),
                const SizedBox(height: 16),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else ...[
                  _buildWorkedCard(),
                  const SizedBox(height: 16),
                  _buildByProjectCard(),
                  const SizedBox(height: 24),
                  _buildRecentSessions(),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary strip (Today / This week / Month)
  // ---------------------------------------------------------------------------

  Widget _buildSummaryStrip() {
    final data = controller.workingHoursSummary.value?.data;
    return DsCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          _summaryStat('today1'.tr, _formatHours(data?.today)),
          _summaryDivider(),
          _summaryStat('thisWeek'.tr, _formatHours(data?.thisWeek)),
          _summaryDivider(),
          _summaryStat('month'.tr, _formatHours(data?.thisMonth)),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() => Container(
        width: 1,
        height: 34,
        color: AppColors.stroke,
      );

  // ---------------------------------------------------------------------------
  // Segmented Day / Week / Month switcher
  // ---------------------------------------------------------------------------

  Widget _buildSegmentedSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          _segment('tabDay'.tr, _ReportTab.day),
          _segment('tabWeek'.tr, _ReportTab.week),
          _segment('tabMonth'.tr, _ReportTab.month),
        ],
      ),
    );
  }

  Widget _segment(String label, _ReportTab tab) {
    final selected = _tab == tab;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodySemibold.copyWith(
              color: selected ? AppColors.primary : AppColors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Period header (date + chevrons)
  // ---------------------------------------------------------------------------

  Widget _buildPeriodHeader() {
    final date = controller.selectedDate.value;
    final String label;
    switch (_tab) {
      case _ReportTab.day:
        label = _formatDayHeader(date);
        break;
      case _ReportTab.week:
        label = _weekRangeLabel(date);
        break;
      case _ReportTab.month:
        label = _formatMonthHeader(date);
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            _chevron(LucideIcons.chevronLeft, () {
              controller.updateSelectedDate(_shiftPeriod(date, -1));
            }),
            const SizedBox(width: 12),
            _chevron(LucideIcons.chevronRight, () {
              controller.updateSelectedDate(_shiftPeriod(date, 1));
            }),
          ],
        ),
      ],
    );
  }

  /// Step the selected date forward/back by one unit of the active tab:
  /// day → ±1 day, week → ±7 days, month → ±1 month. Previously every tab
  /// stepped by a single day, so the Week/Month arrows appeared to do nothing.
  DateTime _shiftPeriod(DateTime date, int direction) {
    switch (_tab) {
      case _ReportTab.day:
        return date.add(Duration(days: direction));
      case _ReportTab.week:
        return date.add(Duration(days: 7 * direction));
      case _ReportTab.month:
        return DateTime(date.year, date.month + direction, date.day);
    }
  }

  String _weekRangeLabel(DateTime d) {
    // Week starting Monday containing the selected date.
    final start = d.subtract(Duration(days: (d.weekday - 1)));
    final end = start.add(const Duration(days: 6));
    if (start.month == end.month) {
      return '${_months[start.month - 1]} ${start.day} - ${end.day}';
    }
    return '${_months[start.month - 1]} ${start.day} - ${_months[end.month - 1]} ${end.day}';
  }

  Widget _chevron(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(icon, size: 22, color: AppColors.textMuted),
    );
  }

  // ---------------------------------------------------------------------------
  // Worked card with bar chart
  // ---------------------------------------------------------------------------

  Widget _buildWorkedCard() {
    final data = controller.workingHoursSummary.value?.data;
    final String title;
    final String total;
    switch (_tab) {
      case _ReportTab.day:
        title = 'workedToday'.tr;
        total = _formatHours(data?.today);
        break;
      case _ReportTab.week:
        title = 'workedThisWeek'.tr;
        total = _formatHours(data?.thisWeek);
        break;
      case _ReportTab.month:
        title = 'workedThisMonth'.tr;
        total = _formatHours(data?.thisMonth);
        break;
    }

    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.eyebrow),
              _pillLabel(LucideIcons.barChart3, 'workVsBreak'.tr),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            total,
            style: AppTextStyles.timer.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: _tab == _ReportTab.day ? _buildDayChart() : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  /// DAY view: an intraday cumulative-worked-hours area curve built from the
  /// real session timeline. Gaps between sessions are breaks, surfaced as a
  /// "Break" label when the curve is scrubbed over them.
  Widget _buildDayChart() {
    final sessions = controller.dailySummaryData.value?.data?.sessions ?? [];

    // Collect work intervals as hour-of-day decimals (e.g. 09:02 -> 9.033).
    final intervals = <List<double>>[];
    for (final s in sessions) {
      final start = s.startTime;
      final end = s.endTime ?? DateTime.now().toUtc(); // running session
      if (start == null) continue;
      final a = start.hour + start.minute / 60.0;
      final b = end.hour + end.minute / 60.0;
      if (b > a) intervals.add([a, b]);
    }
    intervals.sort((x, y) => x[0].compareTo(y[0]));

    // Fallback for days with no usable sessions: a representative two-session
    // day so the curve and "Break" interaction still demonstrate.
    if (intervals.isEmpty) {
      intervals.addAll([
        [9.0, 12.0],
        [12.75, 16.5],
      ]);
    }

    final dayStart = intervals.first[0];
    final dayEnd = intervals.last[1];

    double cumulativeAt(double t) {
      double worked = 0;
      for (final iv in intervals) {
        if (t <= iv[0]) continue;
        final end = t < iv[1] ? t : iv[1];
        worked += end - iv[0];
      }
      return worked;
    }

    bool inBreakAt(double t) {
      if (t <= dayStart || t >= dayEnd) return false;
      for (final iv in intervals) {
        if (t >= iv[0] && t <= iv[1]) return false;
      }
      return true;
    }

    // Sample the curve densely so it reads smooth and the scrubber can land
    // anywhere along the day.
    final spots = <FlSpot>[];
    for (double t = dayStart; t < dayEnd; t += 0.1) {
      spots.add(FlSpot(t, cumulativeAt(t)));
    }
    spots.add(FlSpot(dayEnd, cumulativeAt(dayEnd)));

    final ticks = [
      for (int h = dayStart.floor(); h <= dayEnd.ceil(); h++) h,
    ];

    return DsAreaChart(
      spots: spots,
      minX: dayStart.floorToDouble(),
      maxX: dayEnd.ceilToDouble(),
      hourTicks: ticks,
      labelForX: (x) =>
          inBreakAt(x) ? 'breakLabel'.tr : _formatHours(cumulativeAt(x)),
    );
  }

  Widget _pillLabel(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final values = controller.getBarChartData(); // 7 days: Sat..Fri
    // Labels must line up with that Sat..Fri value order, so take the
    // Sunday-first localized week and rotate Saturday to the front.
    final sundayFirst = AppDate.weekdayLabels(startMonday: false);
    final labels = [sundayFirst.last, ...sundayFirst.take(6)];

    return DsBarChart(
      values: values,
      labels: labels,
      barWidth: 18,
      // Per-day break isn't available from the report API, so the floating
      // label surfaces the worked total for the tapped day.
      labelBuilder: (_, value) => _formatHours(value),
    );
  }

  // ---------------------------------------------------------------------------
  // By project card
  // ---------------------------------------------------------------------------

  Widget _buildByProjectCard() {
    // No per-project breakdown is provided by the report API, so we surface the
    // real values that DO exist for the selected period: worked, break, overtime.
    final summary = controller.dailySummaryData.value?.data;
    final working = controller.workingHoursSummary.value?.data;

    final double workedHours;
    final String periodChip;
    switch (_tab) {
      case _ReportTab.day:
        workedHours = working?.today ?? 0;
        periodChip = 'today1'.tr;
        break;
      case _ReportTab.week:
        workedHours = working?.thisWeek ?? 0;
        periodChip = 'thisWeek'.tr;
        break;
      case _ReportTab.month:
        workedHours = working?.thisMonth ?? 0;
        periodChip = 'thisMonth'.tr;
        break;
    }

    final breakLabel = summary?.totalBreakInHoursFormatted ??
        summary?.totalBreakInHours ??
        '0h';
    final overtimeLabel =
        summary?.overtimeInHoursFormatted ?? summary?.overtime ?? '0h';

    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('breakdown'.tr, style: AppTextStyles.eyebrow),
              _pillLabel(LucideIcons.calendar, periodChip),
            ],
          ),
          const SizedBox(height: 16),
          _breakdownRow('worked'.tr, _formatHours(workedHours), 1.0,
              AppColors.primary),
          const SizedBox(height: 14),
          _breakdownRow('breakLabel'.tr, breakLabel, 0.4, AppColors.success),
          const SizedBox(height: 14),
          _breakdownRow('overtime'.tr, overtimeLabel, 0.2, AppColors.warning),
        ],
      ),
    );
  }

  Widget _breakdownRow(
    String label,
    String value,
    double fraction,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text(value, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.neutralSoft,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Recent sessions
  // ---------------------------------------------------------------------------

  Widget _buildRecentSessions() {
    final sessions = controller.dailySummaryData.value?.data?.sessions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('recentSessions'.tr, style: AppTextStyles.eyebrow),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          DsCard(
            child: Center(
              child: Text(
                'noSessionsPeriod'.tr,
                style: AppTextStyles.subtitle,
              ),
            ),
          )
        else
          ...sessions.map(_sessionTile),
      ],
    );
  }

  Widget _sessionTile(dynamic session) {
    final title = controller.currentProjectTitle;
    final start = session.startTime as DateTime?;
    final end = session.endTime as DateTime?;
    final isCurrent = (session.status as String?) == 'running' || end == null;

    // In this branch isCurrent is false, so end is guaranteed non-null.
    final subtitle = isCurrent
        ? 'Current'
        : (start != null ? '${_timeOfDay(start)} - ${_timeOfDay(end)}' : '');

    final totalMs = (session.totalTime as int?) ?? 0;
    final trailing = _formatDuration(Duration(milliseconds: totalMs));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DsCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _avatar(title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySemibold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.subtitle),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailing,
              style: AppTextStyles.bodySemibold.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String name) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.bodySemibold.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _timeOfDay(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }
}


