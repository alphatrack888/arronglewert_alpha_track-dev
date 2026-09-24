import 'dart:io';
import 'dart:typed_data';

import 'package:alpha_track/services/repository/report_repository/report_repository.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:alpha_track/widgets/app_snackbar/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ReportGenerationState { idle, generating, ready, empty, error }

class ReportsScreenController extends GetxController {
  final ReportRepository _reportRepository = ReportRepository();

  // 'monthly' | 'attendance' — mirrors the same toggle shape already used
  // on the web company dashboard's EmployeeReportModal (Phase 10) for a
  // consistent mental model across platforms.
  var reportType = 'monthly'.obs;
  var month = _currentMonth().obs;
  var startDate = _startOfMonth().obs;
  var endDate = _today().obs;
  var format = 'pdf'.obs;
  var lang = 'en'.obs;

  var state = ReportGenerationState.idle.obs;
  var errorMessage = ''.obs;
  Uint8List? lastReportBytes;
  String lastFileName = '';

  static String _currentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static DateTime _startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime _today() => DateTime.now();

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get isValidRange => !endDate.value.isBefore(startDate.value);

  Future<void> generateReport() async {
    if (reportType.value == 'attendance' && !isValidRange) {
      AppSnackBar.error(AppString.reportEndBeforeStart.tr);
      return;
    }

    state.value = ReportGenerationState.generating;
    errorMessage.value = '';
    lastReportBytes = null;

    final result = reportType.value == 'monthly'
        ? await _reportRepository.fetchMonthlyReport(
            month: month.value,
            format: format.value,
            lang: lang.value,
          )
        : await _reportRepository.fetchAttendanceReport(
            startDate: _dateStr(startDate.value),
            endDate: _dateStr(endDate.value),
            format: format.value,
            lang: lang.value,
          );

    if (!result.success) {
      state.value = ReportGenerationState.error;
      errorMessage.value = result.errorMessage ?? AppString.reportGenerationFailed.tr;
      return;
    }

    if (result.isEmpty || result.bytes == null) {
      state.value = ReportGenerationState.empty;
      return;
    }

    lastReportBytes = Uint8List.fromList(result.bytes!);
    final extension = format.value == 'excel' ? 'xlsx' : 'pdf';
    lastFileName = reportType.value == 'monthly'
        ? 'timesheet-${month.value}.$extension'
        : 'attendance-${_dateStr(startDate.value)}-to-${_dateStr(endDate.value)}.$extension';

    state.value = ReportGenerationState.ready;
  }

  Future<void> downloadReport() async {
    if (lastReportBytes == null) return;
    try {
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
        downloadsDirectory ??= await getApplicationDocumentsDirectory();
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }
      if (downloadsDirectory == null) {
        AppSnackBar.error('Error: Could not access downloads directory');
        return;
      }
      final filePath = '${downloadsDirectory.path}/$lastFileName';
      final file = File(filePath);
      await file.writeAsBytes(lastReportBytes!);
      AppSnackBar.success(AppString.reportDownloaded.tr);
      appLog('Report saved to $filePath');
    } catch (e) {
      appLog('downloadReport error: $e');
      AppSnackBar.error('Error: Failed to save report');
    }
  }

  /// Native share sheet (Phase 13's own explicit ask — the audit flagged
  /// this app as download-to-disk + "open externally" only, with no way to
  /// actually send a report via email/WhatsApp/etc). Writes to a temp file
  /// first since share_plus shares files by path, not raw bytes.
  Future<void> shareReport() async {
    if (lastReportBytes == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$lastFileName';
      final file = File(filePath);
      await file.writeAsBytes(lastReportBytes!);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], fileNameOverrides: [lastFileName]),
      );
    } catch (e) {
      appLog('shareReport error: $e');
      AppSnackBar.error('Error: Failed to share report');
    }
  }

  void reset() {
    state.value = ReportGenerationState.idle;
    lastReportBytes = null;
    errorMessage.value = '';
  }
}
