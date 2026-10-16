import 'package:alpha_track/services/repository/report_repository/report_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BreakHistoryEntry {
  final DateTime day;
  final String projectName;
  final String timeRange;
  final String durationLabel;

  BreakHistoryEntry({
    required this.day,
    required this.projectName,
    required this.timeRange,
    required this.durationLabel,
  });
}

class BreakHistoryController extends GetxController {
  final ReportRepository _reportRepository = ReportRepository();

  final isLoading = true.obs;
  final entries = <BreakHistoryEntry>[].obs;

  static const int _daysToFetch = 7;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      if (kDemoMode) {
        entries.value = _demoEntries();
        return;
      }

      final collected = <BreakHistoryEntry>[];
      final now = DateTime.now();
      final dateFmt = DateFormat('yyyy-MM-dd');
      final timeFmt = DateFormat('HH:mm');

      for (var i = 0; i < _daysToFetch; i++) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final dateStr = dateFmt.format(day);
        final response =
            await _reportRepository.fetchTodayBreakPeriods(todayDate: dateStr);
        if (response.success != true || response.data?.breakPeriods == null) {
          continue;
        }
        for (final period in response.data!.breakPeriods!) {
          if (period.startTime == null || period.endTime == null) continue;
          final start = period.startTime!.toLocal();
          final end = period.endTime!.toLocal();
          final mins = period.durationMinutes ?? 0;
          collected.add(
            BreakHistoryEntry(
              day: day,
              projectName: period.projectName ?? '—',
              timeRange:
                  '${timeFmt.format(start)} – ${timeFmt.format(end)}',
              durationLabel: mins > 0 ? '${mins}m' : '—',
            ),
          );
        }
      }

      entries.value = collected;
    } catch (e) {
      appLog('BreakHistoryController load error: $e');
      entries.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<BreakHistoryEntry> _demoEntries() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return [
      BreakHistoryEntry(
        day: today,
        projectName: 'Demo Project',
        timeRange: '12:30 – 13:05',
        durationLabel: '35m',
      ),
      BreakHistoryEntry(
        day: today,
        projectName: 'Demo Project',
        timeRange: '10:15 – 10:23',
        durationLabel: '8m',
      ),
      BreakHistoryEntry(
        day: yesterday,
        projectName: 'Demo Project',
        timeRange: '12:40 – 13:20',
        durationLabel: '40m',
      ),
    ];
  }
}
