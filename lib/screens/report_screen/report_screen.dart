import 'package:alpha_track/screens/home_screen/main_home/controller/home_screen_controller.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';
import 'package:alpha_track/screens/report_screen/report_period.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_date/app_date.dart';
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

  /// Worked hours for the open day, week, or month. This is the summary
  /// total, the same sessions the bars and session list use.
  double? _periodWorkedHours() {
    return double.tryParse(
      controller.dailySummaryData.value?.data?.totalTime ?? '',
    );
  }

  /// Share a plain-text summary of the current report via the native share
  /// sheet. Worked and break come from the summary for the open period.
  Future<void> _shareReport() async {
    final summary = controller.dailySummaryData.value?.data;

    final breakLabel = summary?.totalBreakInHoursFormatted ?? '0h 0m';

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
    final worked = _formatHours(_periodWorkedHours());

    final text = StringBuffer()
      ..writeln('timeReport'.tr)
      ..writeln(period)
      ..writeln()
      ..writeln('${'worked'.tr}: $worked')
      ..write('${'breakLabel'.tr}: $breakLabel');

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
                _buildStandingCard(),
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
        onTap: () {
          setState(() => _tab = tab);
          controller.setReportPeriod(switch (tab) {
            _ReportTab.week => 'week',
            _ReportTab.month => 'month',
            _ReportTab.day => 'day',
          });
        },
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
    final String title;
    switch (_tab) {
      case _ReportTab.day:
        title = 'workedToday'.tr;
        break;
      case _ReportTab.week:
        title = 'workedThisWeek'.tr;
        break;
      case _ReportTab.month:
        title = 'workedThisMonth'.tr;
        break;
    }
    final total = _formatHours(_periodWorkedHours());

    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.eyebrow),
              _pillLabel(
                LucideIcons.barChart3,
                _tab == _ReportTab.day ? 'workVsBreak'.tr : 'worked'.tr,
              ),
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
    final intervals = workIntervalsLocal(sessions);

    if (intervals.isEmpty) {
      return Center(
        child: Text('noSessionsPeriod'.tr, style: AppTextStyles.subtitle),
      );
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

    final minX = dayStart.floorToDouble();
    final maxX = dayEnd.ceilToDouble();

    return DsAreaChart(
      spots: spots,
      minX: minX,
      maxX: maxX,
      hourTicks: hourAxisTicks(minX, maxX),
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
    final from = controller.reportFrom.value;
    final to = controller.reportTo.value;
    final bars = (controller.dailySummaryData.value?.data?.dailyWorkedHours ??
            const <DailyWorkedHours>[])
        .where((day) {
      final date = day.date;
      if (date == null || date.length < 10) return false;
      if (from.isEmpty || to.isEmpty) return true;
      return date.compareTo(from) >= 0 && date.compareTo(to) <= 0;
    }).toList();
    final values = bars
        .map((day) => double.tryParse(day.hours ?? '') ?? 0)
        .toList();
    if (bars.isEmpty || values.every((hours) => hours == 0)) {
      return Center(
        child: Text('noSessionsPeriod'.tr, style: AppTextStyles.subtitle),
      );
    }

    final labels = bars.map((bar) {
      final date = bar.date ?? '';
      if (_tab == _ReportTab.month) {
        return int.parse(date.substring(8, 10)).toString();
      }
      final weekday = DateTime.parse('${date.substring(0, 10)}T00:00:00.000Z').weekday;
      return AppDate.weekdayLabels(startMonday: true)[weekday - 1];
    }).toList();

    return DsBarChart(
      values: values,
      labels: labels,
      barWidth: bars.length > 14 ? 8 : 18,
      labelBuilder: (_, value) => _formatHours(value),
    );
  }

  // ---------------------------------------------------------------------------
  // Standing totals for in-progress projects. Independent of the open tab.
  // ---------------------------------------------------------------------------

  Widget _buildStandingCard() {
    final standing = controller.standingTotals.value?.data;
    final projectCount = standing?.projectCount ?? 0;
    final allocated = standing?.allocatedHours ?? 0;
    final overtime = standing?.overtimeHours ?? 0;

    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('activeProjects'.tr, style: AppTextStyles.eyebrow),
          if (standing != null && projectCount == 0) ...[
            const SizedBox(height: 16),
            Text('noActiveProjects'.tr, style: AppTextStyles.subtitle),
          ] else if (standing != null) ...[
            const SizedBox(height: 16),
            Text(
              allocated > 0
                  ? '${_formatHours(standing.workedHours)} / ${_formatHours(allocated)}'
                  : _formatHours(standing.workedHours),
              style: AppTextStyles.timer.copyWith(fontSize: 34),
            ),
            if (allocated > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: _standingFill(standing.workedHours ?? 0, allocated),
                  minHeight: 8,
                  backgroundColor: AppColors.neutralSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    overtime > 0 ? AppColors.danger : AppColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _standingFigure('overtime'.tr, _formatHours(overtime)),
                ),
                Expanded(
                  child: _standingFigure(
                    'breakLabel'.tr,
                    _formatHours(standing.breakHours),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _standingFill(double worked, double allocated) {
    if (allocated <= 0) return 0;
    final fraction = worked / allocated;
    if (fraction < 0) return 0;
    if (fraction > 1) return 1;
    return fraction;
  }

  Widget _standingFigure(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Recent sessions
  // ---------------------------------------------------------------------------

  Widget _buildRecentSessions() {
    final sessions = sortedSessionsByStartDesc(
      controller.dailySummaryData.value?.data?.sessions,
    );

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

  Widget _sessionTile(Session session) {
    final projectName = session.project?.name;
    final title = (projectName != null && projectName.isNotEmpty)
        ? projectName
        : '—';
    final start = session.startTime?.toLocal();
    final end = session.endTime?.toLocal();
    final isCurrent = session.endTime == null;

    final subtitle = isCurrent
        ? 'Current'
        : (start != null && end != null
            ? '${_timeOfDay(start)} - ${_timeOfDay(end)}'
            : '');

    final totalMs = session.totalTime ?? 0;
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


