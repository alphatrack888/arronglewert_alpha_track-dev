class AppStorageKey {
  AppStorageKey._privateConstructor();
  static final AppStorageKey _instance = AppStorageKey._privateConstructor();
  static AppStorageKey get instance => _instance;
  String forgotToken = "forgotToken";
  String token = "accessToken";
  String onboard = "onboard";
  String suggestion = "suggestion";
  String refreshToken = "refreshToken";
  String userData = "userData";
  String userRole = "userRole";
  String language = "language";
  String country = "country";
  String reviewToken = "reviewToken";
  String companyId = "companyId";
  String userId = "userId";
  // The FCM token last successfully registered with the backend — kept so
  // logout can deregister the exact token that was registered, and so
  // onTokenRefresh/app-resume checks can tell "already registered" apart
  // from "needs (re-)registering" without an extra network round trip.
  String registeredDeviceToken = "registeredDeviceToken";

  // Offline mark-read queue (Phase 12): notification ids marked read while
  // offline, replayed once connectivity returns.
  String pendingMarkReadIds = "pendingMarkReadIds";
  // Set instead of replaying every queued id individually once a mark-all
  // happened offline too — mark-all supersedes any individually-queued ids.
  String pendingMarkAllRead = "pendingMarkAllRead";

}