import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/home_screen/models/break_hours_model.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/models/today_breaks_periods_model.dart';
import 'package:alpha_track/screens/home_screen/models/standing_totals_model.dart';
import 'package:alpha_track/screens/home_screen/models/working_hours_summary_model.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';

class ReportRepository {
  ApiServices apiServices = ApiServices.instance;

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

  //! Worked, allocation, overtime, and break across in-progress projects.
  Future<StandingTotalsModel> fetchStanding() async {
    try {
      final response = await apiServices.apiGetServices(ApiUrls.projectStanding);
      if (response != null) {
        return StandingTotalsModel.fromJson(response);
      }
      return StandingTotalsModel();
    } catch (e) {
      errorLog("Exception in fetchStanding", e);
      return StandingTotalsModel();
    }
  }

  //! Daily or range summary. [projectId] is optional (report loads all projects).
  Future<DailySummaryModel> fetchDailySummary({
    String? todayData,
    String? projectId,
    String? from,
    String? to,
  }) async {
    try {
      final params = <String, String>{};
      if (from != null &&
          from.isNotEmpty &&
          to != null &&
          to.isNotEmpty) {
        params['from'] = from;
        params['to'] = to;
      } else if (todayData != null && todayData.isNotEmpty) {
        params['date'] = todayData;
      }
      if (projectId != null && projectId.isNotEmpty) {
        params['project'] = projectId;
      }
      final query = params.entries
          .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      final response = await apiServices.apiGetServices(
        '${ApiUrls.timeSummary}?$query',
      );
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
