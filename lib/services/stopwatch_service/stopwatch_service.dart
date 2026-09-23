import 'dart:async';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopwatchService {
  //! SharedPreferences keys
  static const String _elapsedTimeKey = 'elapsed_time';
  static const String _isRunningKey = 'is_running';
  static const String _lastSaveTimeKey = 'last_save_time';
  static const String _sessionIdKey = 'session_id';

  //! Load saved stopwatch data from SharedPreferences
  Future<Map<String, dynamic>> loadStopwatchData(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedElapsedMs = prefs.getInt('$_elapsedTimeKey\_$sessionId') ?? 0;
      final wasRunning = prefs.getBool('$_isRunningKey\_$sessionId') ?? false;
      final lastSaveTime = prefs.getInt('$_lastSaveTimeKey\_$sessionId') ?? 0;

      int adjustedElapsedMs = savedElapsedMs;

      //! If the timer was running when the app was closed, calculate the additional time
      if (wasRunning && lastSaveTime > 0) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final additionalTime = currentTime - lastSaveTime;
        adjustedElapsedMs = savedElapsedMs + additionalTime;
      }

      return {
        'elapsedMs': adjustedElapsedMs,
        'wasRunning': wasRunning,
        'lastSaveTime': lastSaveTime,
      };
    } catch (e) {
      appLog('Error loading stopwatch data: $e');
      return {
        'elapsedMs': 0,
        'wasRunning': false,
        'lastSaveTime': 0,
      };
    }
  }

  //! Save current stopwatch state to SharedPreferences
  Future<void> saveStopwatchData({
    required int elapsedMs,
    required bool isRunning,
    required String sessionId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_elapsedTimeKey\_$sessionId', elapsedMs);
      await prefs.setBool('$_isRunningKey\_$sessionId', isRunning);
      await prefs.setInt(
          '$_lastSaveTimeKey\_$sessionId', DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_sessionIdKey, sessionId);
    } catch (e) {
      appLog('Error saving stopwatch data: $e');
    }
  }

  //! Clear all stopwatch data
  Future<void> clearAllStopwatchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_elapsedTimeKey);
      await prefs.remove(_isRunningKey);
      await prefs.remove(_lastSaveTimeKey);
      await prefs.remove(_sessionIdKey);
    } catch (e) {
      appLog('Error clearing stopwatch data: $e');
    }
  }

  //! Clear single stopwatch data
  Future<void> clearStopwatchData(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_elapsedTimeKey\_$sessionId');
      await prefs.remove('$_isRunningKey\_$sessionId');
      await prefs.remove('$_lastSaveTimeKey\_$sessionId');
    } catch (e) {
      appLog('Error clearing stopwatch data: $e');
    }
  }
}
