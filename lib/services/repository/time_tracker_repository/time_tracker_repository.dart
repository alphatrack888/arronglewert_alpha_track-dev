import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/services/api/timer_api.dart';

export 'package:alpha_track/services/api/timer_api.dart' show OpenTimeSession;

/// Result of POST /timetracker/pause. A missing start means the pause saved
/// without an instant the phone can count from.
class PauseTimerOutcome {
  const PauseTimerOutcome.failed() : ok = false, pauseStartedAt = null;

  const PauseTimerOutcome.ok(this.pauseStartedAt) : ok = true;

  final bool ok;
  final DateTime? pauseStartedAt;
}

DateTime? _pauseStartFromBody(dynamic response) {
  if (response is! Map) return null;
  final data = response['data'];
  if (data is! Map) return null;
  final pauses = data['pauses'];
  if (pauses is! List || pauses.isEmpty) return null;
  final last = pauses.last;
  if (last is! Map) return null;
  final start = last['start'];
  if (start is! String || start.isEmpty) return null;
  return DateTime.tryParse(start);
}

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

  //! Pause Timer. [pauseStartedAt] is the server pause instant when the body includes it.
  Future<PauseTimerOutcome> pauseTimer({
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
        return PauseTimerOutcome.ok(_pauseStartFromBody(response));
      }
      return const PauseTimerOutcome.failed();
    } catch (e) {
      return const PauseTimerOutcome.failed();
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
