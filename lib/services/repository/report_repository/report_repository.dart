import 'dart:convert';

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/home_screen/models/break_hours_model.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/models/today_breaks_periods_model.dart';
import 'package:alpha_track/screens/home_screen/models/working_hours_summary_model.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:http/http.dart' as http;

/// Result of a report fetch — binary content, not JSON, so this doesn't fit
/// ApiServices' JSON-oriented methods (same reasoning the existing
/// PayroleScreenController.downloadPdf already applied: a raw `http` GET
/// with the bearer token attached manually).
class ReportFetchResult {
  final bool success;
  final List<int>? bytes;
  final String? errorMessage;
  final bool isEmpty;

  ReportFetchResult.ok(this.bytes) : success = true, errorMessage = null, isEmpty = false;
  ReportFetchResult.error(this.errorMessage) : success = false, bytes = null, isEmpty = false;
  ReportFetchResult.empty() : success = true, bytes = null, errorMessage = null, isEmpty = true;
}

class ReportRepository {
  ApiServices apiServices = ApiServices.instance;
  final StorageServices _storageServices = StorageServices.instance;

  /// Phase 13: the monthly timesheet report (Phase 5 backend). Always
  /// scoped to the calling employee's own data — no `employee` param is
  /// sent, since the backend ignores it for the EMPLOYEES role anyway.
  Future<ReportFetchResult> fetchMonthlyReport({
    required String month, // YYYY-MM
    String format = 'pdf',
    String lang = 'en',
  }) async {
    return _fetchReportBytes(
      '${ApiUrls.reportMonthly}?month=$month&format=$format&lang=$lang',
    );
  }

  /// Phase 13: the attendance report (Phase 5 backend), same self-only
  /// scoping as above.
  Future<ReportFetchResult> fetchAttendanceReport({
    required String startDate, // YYYY-MM-DD
    required String endDate, // YYYY-MM-DD
    String format = 'pdf',
    String lang = 'en',
  }) async {
    return _fetchReportBytes(
      '${ApiUrls.reportAttendance}?startDate=$startDate&endDate=$endDate&format=$format&lang=$lang',
    );
  }

  Future<ReportFetchResult> _fetchReportBytes(String url) async {
    try {
      final token = _storageServices.getAccessToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          return ReportFetchResult.empty();
        }
        return ReportFetchResult.ok(response.bodyBytes);
      }

      // Backend errors (validation, forbidden, etc.) come back as JSON with
      // a `message` field, not the binary body a 200 would carry.
      String message = 'Failed to generate report (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] is String) {
          message = decoded['message'];
        }
      } catch (_) {
        // Not JSON (or unexpected shape) — keep the generic message.
      }
      return ReportFetchResult.error(message);
    } catch (e) {
      appLog("ReportRepository._fetchReportBytes error: $e");
      return ReportFetchResult.error('Network error while generating report');
    }
  }

  //! Break hours
  Future<BreakHoursModel> fetchBreakHoursByDay() async {
    try {
      final response = await apiServices.apiGetServices(ApiUrls.breakHours);
      if (response != null) {
        return BreakHoursModel.fromJson(response);
      }
      return BreakHoursModel();
    } catch (e) {
      errorLog("Exception in fetchBreakHoursByDay", e);
      return BreakHoursModel();
    }
  }

  //! Today's break Periods
  Future<TodayBreakPeriodsModel> fetchTodayBreakPeriods({
    required String todayDate,
  }) async {
    try {
      final response = await apiServices.apiGetServices(
        ApiUrls.todayBreakPeriods + todayDate,
      );
      if (response != null) {
        return TodayBreakPeriodsModel.fromJson(response);
      }
      return TodayBreakPeriodsModel();
    } catch (e) {
      errorLog("Exception in fetchTodayBreakPeriods", e);
      return TodayBreakPeriodsModel();
    }
  }

  //! Working Hours Summary
  Future<WorkingHoursSummaryModel> fetchWorkingHoursSummary({
    required String todayDate,
  }) async {
    try {
      final response = await apiServices.apiGetServices(
        ApiUrls.worksHoursSummary + todayDate,
      );
      if (response != null) {
        return WorkingHoursSummaryModel.fromJson(response);
      }
      return WorkingHoursSummaryModel();
    } catch (e) {
      errorLog("Exception in fetchWorkingHoursSummary", e);
      return WorkingHoursSummaryModel();
    }
  }

  //! Daily Summary
  Future<DailySummaryModel> fetchDailySummary({
    required String todayData,
    required String projectId,
  }) async {
    try {
      final response = await apiServices.apiGetServices("${ApiUrls.dailySummary}$todayData&project=$projectId");
      if (response != null) {
        return DailySummaryModel.fromJson(response);
      }
      return DailySummaryModel();
    } catch (e) {
      errorLog("Exception in fetchDailySummary", e);
      return DailySummaryModel();
    }
  }
}
