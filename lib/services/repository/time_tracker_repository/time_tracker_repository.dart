import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/api/api_services.dart';

class TimeTrackerRepository {
  ApiServices apiServices = ApiServices.instance;

  Future<String?> startTimer({
    required String projectID,
    required double lat,
    required double lng,
  }) async {
    try {
      final body = {
        "project": projectID,
        "location": {"lat": lat, "lng": lng},
      };

      final response = await apiServices.apiPostServices(
        url: ApiUrls.startTimer,
        body: body,
      );

      if (response != null && response["success"] == true) {
        return response["data"]["_id"];
      }
      return null;
    } catch (e) {
      return null;
    }
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
