import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/break_screen/break_screen/controller/break_screen_controller.dart';
import 'package:alpha_track/screens/break_screen/leave_screen/controller/leave_screen_controller.dart';
import 'package:alpha_track/screens/break_screen/model/leave_balance_left.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/ds/ds_buttons.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_chip.dart';
import 'package:alpha_track/widgets/app_text_field/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:alpha_track/utils/app_date/app_date.dart';

/// Leave Schedule — matches Figma 73-3487 (month calendar + leave balance).
class LeaveScheduleScreen extends StatefulWidget {
  const LeaveScheduleScreen({super.key});

  @override
  State<LeaveScheduleScreen> createState() => _LeaveScheduleScreenState();
}

class _LeaveScheduleScreenState extends State<LeaveScheduleScreen> {
  final BreakScreenController controller = Get.put(BreakScreenController());
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Type → accent colour for calendar highlights + balance dots.
  Color _typeColor(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'sick':
        return const Color(0xFFF5B6D0);
      case 'earn':
        return const Color(0xFF8FE0D0);
      case 'wp':
      case 'without pay':
        return const Color(0xFFE9856B);
      case 'casual':
      default:
        return const Color(0xFFC7E89B);
    }
  }

  String _typeName(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'sick':
        return 'sickLeave'.tr;
      case 'earn':
        return 'earnLeave'.tr;
      case 'wp':
        return 'withoutPay'.tr;
      case 'casual':
        return 'casualLeave'.tr;
      default:
        return type ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final data = controller.leaveBalanceHistoryData.value?.data;
          final leaves = data?.leavemanagements ?? <Leavemanagement>[];
          final upcoming = _upcomingLeaves(leaves);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _calendar(leaves),
                if (upcoming.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('upcomingLeaves'.tr, style: AppTextStyles.eyebrow),
                  const SizedBox(height: 12),
                  ...upcoming.map(_upcomingCard),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('leaveBalance'.tr, style: AppTextStyles.eyebrow),
                    GestureDetector(
                      onTap: _showApplyLeaveSheet,
                      child: Text('applyLeave'.tr,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _balanceTable(data?.companyLeaveBalance ?? []),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(LucideIcons.arrowLeft,
                size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('leaveSchedule'.tr, style: AppTextStyles.title)),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoute.leaveHistoryScreen),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(LucideIcons.history,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  // ---- Calendar -------------------------------------------------------------
  Widget _calendar(List<Leavemanagement> leaves) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7; // Sun=0
    final today = DateTime.now();

    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      final leaveColor = _leaveColorFor(date, leaves);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      cells.add(_dayCell(d, isToday: isToday, highlight: leaveColor));
    }

    return DsCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_months[_month.month - 1]} ${_month.year}',
                  style: AppTextStyles.titleSmall),
              Row(children: [
                _navBtn(LucideIcons.chevronLeft, () => setState(() {
                      _month = DateTime(_month.year, _month.month - 1);
                    })),
                const SizedBox(width: 8),
                _navBtn(LucideIcons.chevronRight, () => setState(() {
                      _month = DateTime(_month.year, _month.month + 1);
                    })),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            // Calendar grid starts on Sunday (see firstWeekday above).
            children: AppDate.weekdayLabels(startMonday: false)
                .map((d) => Expanded(
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textFaint)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: cells,
          ),
        ],
      ),
    );
  }

  DateTime get _startOfToday {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Color? _leaveColorFor(DateTime date, List<Leavemanagement> leaves) {
    for (final l in leaves) {
      if (l.from == null || l.to == null) continue;
      // A rejected leave was never taken, so it never colours the calendar.
      if ((l.status ?? '').toLowerCase() == 'rejected') continue;
      final from = DateTime(l.from!.year, l.from!.month, l.from!.day);
      final to = DateTime(l.to!.year, l.to!.month, l.to!.day);
      if (!date.isBefore(from) && !date.isAfter(to)) {
        final base = _typeColor(l.type);
        // Past (finished) leaves render shaded; upcoming keep their full colour.
        return to.isBefore(_startOfToday)
            ? base.withValues(alpha: 0.30)
            : base;
      }
    }
    return null;
  }

  /// Upcoming = approved or pending leaves whose end date is today or later,
  /// soonest first. Rejected and finished leaves live in History instead.
  List<Leavemanagement> _upcomingLeaves(List<Leavemanagement> leaves) {
    final list = leaves.where((l) {
      final s = (l.status ?? '').toLowerCase();
      if (s != 'approved' && s != 'pending') return false;
      if (l.to == null) return false;
      final to = DateTime(l.to!.year, l.to!.month, l.to!.day);
      return !to.isBefore(_startOfToday);
    }).toList()
      ..sort((a, b) =>
          (a.from ?? DateTime(2100)).compareTo(b.from ?? DateTime(2100)));
    return list;
  }

  String _fmtShort(DateTime? d) =>
      d == null ? '—' : '${_months[d.month - 1].substring(0, 3)} ${d.day}';

  Widget _upcomingCard(Leavemanagement l) {
    final range = (l.from != null && l.to != null && l.from != l.to)
        ? '${_fmtShort(l.from)} – ${_fmtShort(l.to)}'
        : _fmtShort(l.from);
    final isApproved = (l.status ?? '').toLowerCase() == 'approved';
    return DsCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _typeColor(l.type),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.palmtree,
                size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_typeName(l.type)} leave',
                    style: AppTextStyles.bodySemibold),
                const SizedBox(height: 2),
                Text('$range • ${l.totalDays ?? 0}d',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          isApproved
              ? DsChip.success('Approved')
              : DsChip.warning('Pending'),
        ],
      ),
    );
  }

  Widget _dayCell(int day, {required bool isToday, Color? highlight}) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary
            : (highlight ?? Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text('$day',
          style: AppTextStyles.body.copyWith(
            color: isToday ? AppColors.white50 : AppColors.textPrimary,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          )),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: AppColors.textMuted),
    );
  }

  // ---- Balance table --------------------------------------------------------
  Widget _balanceTable(List<CompanyLeaveBalance> rows) {
    return DsCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 4, child: _th('Type')),
                Expanded(flex: 2, child: _th('Taken')),
                Expanded(flex: 2, child: _th('Balance')),
                Expanded(flex: 3, child: _th('Status')),
              ],
            ),
          ),
          ...rows.map((r) => Column(
                children: [
                  const Divider(height: 1, color: AppColors.stroke),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: _typeColor(r.type),
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(_typeName(r.type),
                                  style: AppTextStyles.bodyMedium,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        ),
                        Expanded(flex: 2, child: Text('${r.taken ?? 0}', style: AppTextStyles.body)),
                        Expanded(flex: 2, child: Text('${r.balance ?? 0}', style: AppTextStyles.body)),
                        Expanded(
                          flex: 3,
                          child: Text(
                            (r.status ?? 'active') == 'active' ? 'activeStatus'.tr : (r.status ?? ''),
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _th(String t) =>
      Text(t, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted));

  // ---- Apply Leave bottom sheet --------------------------------------------
  void _showApplyLeaveSheet() {
    final c = Get.put(LeaveScreenController());
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    Future<void> pickDate(bool isFrom) async {
      final picked = await showDatePicker(
        context: Get.context!,
        initialDate: isFrom ? c.fromDate.value : c.toDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        isFrom ? c.updateFromDate(picked) : c.updateToDate(picked);
      }
    }

    Widget label(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(t,
              style: AppTextStyles.caption.copyWith(fontSize: 13)),
        );

    Widget dateField(String lbl, bool isFrom) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label(lbl),
              GestureDetector(
                onTap: () => pickDate(isFrom),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmt(isFrom ? c.fromDate.value : c.toDate.value),
                              style: AppTextStyles.body),
                          const Icon(LucideIcons.chevronDown,
                              size: 18, color: AppColors.textMuted),
                        ],
                      )),
                ),
              ),
            ],
          ),
        );

    DsBottomSheet.show(
      Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: DsBottomSheet(
          title: 'applyLeave'.tr,
          trailing: GestureDetector(
            onTap: Get.back,
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textMuted)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('leaveType'.tr),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: c.selectedLeaveType.value,
                          icon: const Icon(LucideIcons.chevronDown,
                              size: 18, color: AppColors.textMuted),
                          items: c.leaveTypes
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.tr, style: AppTextStyles.body),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) c.updateLeaveType(v);
                          },
                        ),
                      )),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  dateField('fromDate'.tr, true),
                  const SizedBox(width: 14),
                  dateField('toDate'.tr, false),
                ]),
                const SizedBox(height: 16),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                          'leaveDurationDays'.trParams({'n': '${c.leaveDuration}'}),
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                    )),
                const SizedBox(height: 16),
                label('leaveReason'.tr),
                CustomTextField(
                  controller: c.reasonController,
                  hintText: 'typeHere'.tr,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Obx(() => PrimaryButton(
                      label: 'applyForDayLeave'.trParams({'n': '${c.leaveDuration}'}),
                      isTranslate: false,
                      isLoading: c.isLoading.value,
                      onTap: c.isLoading.value
                          ? null
                          : () async {
                              final ok = await c.applyLeaveFromSheet();
                              if (ok) Get.back(); // close the sheet
                            },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
