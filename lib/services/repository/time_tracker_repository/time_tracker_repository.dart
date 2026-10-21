import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/api/timer_api.dart';

export 'package:alpha_track/services/api/timer_api.dart' show OpenTimeSession;

class TimeTrackerRepository {
  ApiServices apiServices = ApiServices.instance;

  /// Null when the request fails. Empty when the employee has no open session.
  Future<List<OpenTimeSession>?> getOpenSessions() => fetchOpenSessions();

  Future<ApiCallResult<String>> startTimer({
    required String projectID,
    required double lat,
    required double lng,
  }) async {
    return postStartTimer(projectId: projectID, lat: lat, lng: lng);
  }

  //! Pause Timer
  Future<bool> pauseTimer({
    required String sessionID,
    required double lat,
    required double lng,
  }) async {
    try {
      final body = {
        "sessionId": sessionID,
        "location": {"lat": lat, "lng": lng},
      };
      final response = await apiServices.apiPostServices(
        url: ApiUrls.pauseTimer + sessionID,
        body: body,
      );
      if (response != null && response["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //! Resume Timer
  Future<bool> resumeTimer({
    required String sessionID,
    required double lat,
    required double lng,
  }) async {
    try {
      final body = {
        "sessionId": sessionID,
        "location": {"lat": lat, "lng": lng},
      };
      final response = await apiServices.apiPostServices(
        url: ApiUrls.resumeTimer + sessionID,
        body: body,
      );
      if (response != null && response["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //! Stop Timer
  Future<bool> stopTimer({
    required String sessionID,
    required double lat,
    required double lng,
  }) async {
    try {
      final body = {
        "location": {"lat": lat, "lng": lng},
      };
      final response = await apiServices.apiPostServices(
        url: "${ApiUrls.stopTimer}$sessionID",
        body: body,
      );
      if (response != null && response["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  
}
