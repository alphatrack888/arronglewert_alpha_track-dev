import 'package:alpha_track/core/constant/app_storage_key.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  StorageServices._privateConstructor();

  static final StorageServices _instance =
      StorageServices._privateConstructor();

  static StorageServices get instance => _instance;

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Initialize storage with SharedPreferences only
  Future<void> initializeStorage() async {
    try {
      if (!_isInitialized) {
        await initializeFallbackStorage();
      }
    } catch (e) {
      errorLog('Storage initialization error', e);
      rethrow;
    }
  }

  // Initialize SharedPreferences storage
  Future<void> initializeFallbackStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('SharedPreferences initialized successfully');
    } catch (prefsError) {
      errorLog('SharedPreferences initialization failed', prefsError);
      rethrow;
    }
  }

  // Safe write operation
  Future<void> _safeWrite(String key, dynamic value) async {
    try {
      if (_prefs != null && _isInitialized) {
        if (value is String) {
          await _prefs!.setString(key, value);
        } else if (value is bool) {
          await _prefs!.setBool(key, value);
        } else if (value is int) {
          await _prefs!.setInt(key, value);
        } else if (value is double) {
          await _prefs!.setDouble(key, value);
        } else if (value is List<String>) {
          await _prefs!.setStringList(key, value);
        } else {
          // Convert complex objects to string
          await _prefs!.setString(key, value.toString());
        }
      }
    } catch (e) {
      errorLog('Safe write error for key: $key', e);
    }
  }

  // Safe read operation
  T? _safeRead<T>(String key, [T? defaultValue]) {
    try {
      if (_prefs != null && _isInitialized) {
        return _prefs!.get(key) as T? ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      errorLog('Safe read error for key: $key', e);
      return defaultValue;
    }
  }

  bool get isInitialized => _isInitialized;

  // Location storage keys
  static const String _currentLatKey = 'current_latitude';
  static const String _currentLngKey = 'current_longitude';
  static const String _locationTimestampKey = 'location_timestamp';
  static const String _locationHistoryKey = 'location_history';

  // Token methods with fallback support
  Future<void> setAccessToken(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.token, value);
      // Verify write in release mode
      final verified = _safeRead<String>(AppStorageKey.instance.token);
      if (verified != value) {
        errorLog(
          "Token verification failed after write",
          "Expected: $value, Got: $verified",
        );
        // Retry once
        await _safeWrite(AppStorageKey.instance.token, value);
      }
    } catch (e) {
      errorLog("set token", e);
      rethrow; // Rethrow to let caller know about the error
    }
  }

  String getAccessToken() {
    try {
      final token = _safeRead<String>(AppStorageKey.instance.token) ?? "";
      if (token.isEmpty) {
        print("WARNING: getAccessToken returned empty string");
      }
      return token;
    } catch (e) {
      errorLog("get token", e);
      return "";
    }
  }

  Future<void> setRefreshToken(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.refreshToken, value);
    } catch (e) {
      errorLog("set refresh token", e);
    }
  }

  String getRefreshToken() {
    try {
      return _safeRead<String>(AppStorageKey.instance.refreshToken) ?? "";
    } catch (e) {
      errorLog("get refresh token", e);
      return "";
    }
  }

  // UserId methods
  Future<void> setUserId(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.userId, value);
    } catch (e) {
      errorLog("set user id", e);
    }
  }

  String getUserId() {
    try {
      return _safeRead<String>(AppStorageKey.instance.userId) ?? "";
    } catch (e) {
      errorLog("get user id", e);
      return "";
    }
  }

  // The FCM token last successfully registered with the backend (Phase 11).
  Future<void> setRegisteredDeviceToken(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.registeredDeviceToken, value);
    } catch (e) {
      errorLog("set registered device token", e);
    }
  }

  String getRegisteredDeviceToken() {
    try {
      return _safeRead<String>(AppStorageKey.instance.registeredDeviceToken) ?? "";
    } catch (e) {
      errorLog("get registered device token", e);
      return "";
    }
  }

  // Offline mark-read queue (Phase 12).
  List<String> getPendingMarkReadIds() {
    try {
      return _prefs?.getStringList(AppStorageKey.instance.pendingMarkReadIds) ?? [];
    } catch (e) {
      errorLog("get pending mark-read ids", e);
      return [];
    }
  }

  Future<void> addPendingMarkReadId(String id) async {
    try {
      final current = getPendingMarkReadIds();
      if (!current.contains(id)) {
        current.add(id);
        await _safeWrite(AppStorageKey.instance.pendingMarkReadIds, current);
      }
    } catch (e) {
      errorLog("add pending mark-read id", e);
    }
  }

  Future<void> clearPendingMarkReadIds() async {
    try {
      await _safeWrite(AppStorageKey.instance.pendingMarkReadIds, <String>[]);
    } catch (e) {
      errorLog("clear pending mark-read ids", e);
    }
  }

  Future<void> setPendingMarkAllRead(bool value) async {
    try {
      await _safeWrite(AppStorageKey.instance.pendingMarkAllRead, value);
    } catch (e) {
      errorLog("set pending mark-all-read", e);
    }
  }

  bool getPendingMarkAllRead() {
    try {
      return _safeRead<bool>(AppStorageKey.instance.pendingMarkAllRead) ?? false;
    } catch (e) {
      errorLog("get pending mark-all-read", e);
      return false;
    }
  }

  // Forgot password token
  Future<void> setForgotPasswordToken(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.forgotToken, value);
    } catch (e) {
      errorLog("set forgot password token", e);
    }
  }

  String getForgotPasswordToken() {
    try {
      return _safeRead<String>(AppStorageKey.instance.forgotToken) ?? "";
    } catch (e) {
      errorLog("get forgot password token", e);
      return "";
    }
  }

  // Onboard screen methods
  Future<void> setOnboardScreen() async {
    try {
      await _safeWrite(AppStorageKey.instance.onboard, true);
    } catch (e) {
      errorLog("setOnboardScreen", e);
    }
  }

  bool getOnboardScreen() {
    try {
      return _safeRead<bool>(AppStorageKey.instance.onboard) ?? false;
    } catch (e) {
      errorLog("getOnboardScreen", e);
      return false;
    }
  }

  // User role methods
  Future<void> setUserRole(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.userRole, value);
    } catch (e) {
      errorLog("set user role", e);
    }
  }

  String? getUserRole() {
    try {
      return _safeRead<String>(AppStorageKey.instance.userRole);
    } catch (e) {
      errorLog("get user role", e);
      return "";
    }
  }

  // Company ID methods
  Future<void> setCompanyId(String value) async {
    try {
      await _safeWrite(AppStorageKey.instance.companyId, value);
    } catch (e) {
      errorLog("set company id", e);
    }
  }

  String getCompanyId() {
    try {
      return _safeRead<String>(AppStorageKey.instance.companyId) ?? "";
    } catch (e) {
      errorLog("get company id", e);
      return "";
    }
  }

  // Language methods
  String? getLanguage() {
    return _safeRead<String>(AppStorageKey.instance.language);
  }

  Future<void> setLanguage(String value) async {
    await _safeWrite(AppStorageKey.instance.language, value);
  }

  // Location methods (simplified for SharedPreferences compatibility)
  Future<void> saveCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _safeWrite(_currentLatKey, latitude);
      await _safeWrite(_currentLngKey, longitude);
      await _safeWrite(
        _locationTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      errorLog('Error saving current location', e);
    }
  }

  Map<String, dynamic>? getCurrentLocation() {
    try {
      final lat = _safeRead<double>(_currentLatKey);
      final lng = _safeRead<double>(_currentLngKey);
      final timestamp = _safeRead<int>(_locationTimestampKey);

      if (lat != null && lng != null) {
        return {'latitude': lat, 'longitude': lng, 'timestamp': timestamp ?? 0};
      }
      return null;
    } catch (e) {
      errorLog('Error getting current location', e);
      return null;
    }
  }

  // For complex data like location history, use simplified storage
  Future<void> saveLocationToHistory({
    required double latitude,
    required double longitude,
    String? activity,
  }) async {
    try {
      // Just save the latest location in SharedPreferences mode
      await saveCurrentLocation(latitude: latitude, longitude: longitude);
    } catch (e) {
      errorLog('Error saving location to history', e);
    }
  }

  List<Map<String, dynamic>> getLocationHistory() {
    try {
      // Return current location as single item list
      final currentLocation = getCurrentLocation();
      return currentLocation != null ? [currentLocation] : [];
    } catch (e) {
      errorLog('Error getting location history', e);
      return [];
    }
  }

  List<Map<String, dynamic>> getLocationHistoryForDate(DateTime date) {
    try {
      List<Map<String, dynamic>> allHistory = getLocationHistory();
      String targetDate = DateTime(
        date.year,
        date.month,
        date.day,
      ).toIso8601String().split('T')[0];

      return allHistory.where((entry) {
        String entryDate = entry['date']?.split('T')[0] ?? '';
        return entryDate == targetDate;
      }).toList();
    } catch (e) {
      errorLog('Error getting location history for date', e);
      return [];
    }
  }

  Future<void> clearLocationData() async {
    try {
      if (_prefs != null && _isInitialized) {
        await _prefs!.remove(_currentLatKey);
        await _prefs!.remove(_currentLngKey);
        await _prefs!.remove(_locationTimestampKey);
        await _prefs!.remove(_locationHistoryKey);
      }
    } catch (e) {
      errorLog('Error clearing location data', e);
    }
  }

  List<Map<String, dynamic>> getTodayWorkLocations() {
    try {
      return getLocationHistoryForDate(
        DateTime.now(),
      ).where((entry) => entry['activity'] == 'working').toList();
    } catch (e) {
      errorLog('Error getting today work locations', e);
      return [];
    }
  }

  Future<void> saveWorkSessionLocation({
    required double latitude,
    required double longitude,
    required String sessionType,
  }) async {
    try {
      await saveCurrentLocation(latitude: latitude, longitude: longitude);
      await saveLocationToHistory(
        latitude: latitude,
        longitude: longitude,
        activity: sessionType,
      );
    } catch (e) {
      errorLog('Error saving work session location', e);
    }
  }

  Future<void> storageClear() async {
    try {
      await _safeWrite(AppStorageKey.instance.token, "");
      await setLanguage("english");
      await clearLocationData();
    } catch (e) {
      errorLog("logout", e);
    }
  }

  // Generic data methods
  Future<void> saveData(String key, dynamic value) async {
    try {
      await _safeWrite(key, value);
    } catch (e) {
      errorLog("saveData - key: $key", e);
    }
  }

  dynamic getData(String key) {
    try {
      return _safeRead(key);
    } catch (e) {
      errorLog("getData - key: $key", e);
      return null;
    }
  }
}
