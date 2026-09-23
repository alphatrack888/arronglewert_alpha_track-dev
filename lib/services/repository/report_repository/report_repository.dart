import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/home_screen/models/break_hours_model.dart';
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/models/today_breaks_periods_model.dart';
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
