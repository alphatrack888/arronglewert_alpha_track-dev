import 'package:alpha_track/screens/break_screen/break_screen/controller/break_screen_controller.dart';
import 'package:alpha_track/screens/break_screen/model/leave_balance_left.dart';
import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_card.dart';
import 'package:alpha_track/widgets/ds/ds_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
String _d(DateTime? d) =>
    d == null ? '—' : '${_months[d.month - 1]} ${d.day}, ${d.year}';

Widget _historyScaffold(String title, Widget body) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const DsBackButton(),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.title),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    ),
  );
}

/// Past leave requests (uses BreakScreenController leave history).
class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  Color _typeColor(String? t) {
    switch ((t ?? '').toLowerCase()) {
      case 'sick':
        return const Color(0xFFF5B6D0);
      case 'earn':
        return const Color(0xFF8FE0D0);
      case 'wp':
        return const Color(0xFFE9856B);
      default:
        return const Color(0xFFC7E89B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BreakScreenController());
    return _historyScaffold(
      'leaveHistory'.tr,
      Obx(() {
        final all =
            controller.leaveBalanceHistoryData.value?.data?.leavemanagements ??
                <Leavemanagement>[];
        // History = finished (any past leave) + rejected. Upcoming pending/
        // approved leaves live in the Leave Schedule "Upcoming" section instead.
        final now = DateTime.now();
        final startToday = DateTime(now.year, now.month, now.day);
        final items = all.where((l) {
          if ((l.status ?? '').toLowerCase() == 'rejected') return true;
          if (l.to == null) return false;
          final to = DateTime(l.to!.year, l.to!.month, l.to!.day);
          return to.isBefore(startToday);
        }).toList()
          ..sort((a, b) =>
              (b.from ?? DateTime(2000)).compareTo(a.from ?? DateTime(2000)));
        if (items.isEmpty) {
          return Center(
              child: Text('noLeaveHistory'.tr, style: AppTextStyles.subtitle));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final l = items[i];
            return DsCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: _typeColor(l.type).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.palmtree,
                        size: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(l.type ?? '').isEmpty ? 'leaveWord'.tr : l.type![0].toUpperCase()}${(l.type ?? '').length > 1 ? l.type!.substring(1) : ''} ${'leaveWord'.tr}',
                          style: AppTextStyles.bodySemibold,
                        ),
                        const SizedBox(height: 2),
                        Text('${_d(l.from)} – ${_d(l.to)} • ${l.totalDays ?? 0}d',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  (l.status ?? '').toLowerCase() == 'rejected'
                      ? DsChip.danger('Rejected')
                      : DsChip.success('Approved'),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Past breaks (demo list).
class BreakHistoryScreen extends StatelessWidget {
  const BreakHistoryScreen({super.key});

  static const _breaks = [
    {'title': 'lunch', 'date': 'today1', 'time': '12:30 – 13:05', 'dur': '35m'},
    {'title': 'coffee', 'date': 'today1', 'time': '10:15 – 10:23', 'dur': '8m'},
    {'title': 'lunch', 'date': 'yesterday', 'time': '12:40 – 13:20', 'dur': '40m'},
    {'title': 'shortBreak', 'date': 'yesterday', 'time': '15:00 – 15:10', 'dur': '10m'},
    {'title': 'lunch', 'date': 'Jun 12', 'time': '12:30 – 13:00', 'dur': '30m'},
  ];

  @override
  Widget build(BuildContext context) {
    // Group breaks by their date label, preserving first-seen order, so the
    // list reads: Today → its breaks, Yesterday → its breaks, etc.
    final groups = <String, List<Map<String, String>>>{};
    for (final b in _breaks) {
      groups.putIfAbsent(b['date']!, () => []).add(b);
    }

    final children = <Widget>[];
    groups.forEach((date, items) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(date.tr.toUpperCase(), style: AppTextStyles.eyebrow),
      ));
      for (final b in items) {
        children.add(_breakCard(b));
      }
    });

    return _historyScaffold(
      'breakHistory'.tr,
      ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: children,
      ),
    );
  }

  Widget _breakCard(Map<String, String> b) {
    return DsCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFFE9856B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.coffee,
                size: 18, color: Color(0xFFE9856B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b['title']!.tr, style: AppTextStyles.bodySemibold),
                const SizedBox(height: 2),
                Text(b['time']!, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(b['dur']!, style: AppTextStyles.bodySemibold),
        ],
      ),
    );
  }
}
