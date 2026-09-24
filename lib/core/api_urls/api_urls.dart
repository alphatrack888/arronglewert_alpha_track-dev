class ApiUrls {
  ApiUrls._();
  static const String liveDomain = "https://api.alphatrack.app/";
  static const String localDomain = "http://88.198.112.109:5000/";
  static const String baseUrl = "${liveDomain}api/v1";
  static const String employeeLogin = "$baseUrl/auth/login";
  static const String verifyAccount = "$baseUrl/auth/verify-account";
  static const String resendOtp = "$baseUrl/auth/resend-otp";
  static const String forgotPassword = "$baseUrl/auth/forget-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String changePasswrod = "$baseUrl/auth/change-password";

  static const String allProject = "$baseUrl/project";
  static const String singleProject = "$baseUrl/project/";
  static const String startTimer = "$baseUrl/timetracker/start";
  static const String pauseTimer = "$baseUrl/timetracker/pause/";
  static const String resumeTimer = "$baseUrl/timetracker/resume/";
  static const String stopTimer = "$baseUrl/timetracker/stop/";
  static const String profile = "$baseUrl/user/profile";
  static const String leaveBalance = "$baseUrl/leavebalance/company/";
  static const String leaveManagement = "$baseUrl/leavemanagement";
  static const String updateProfile = "$baseUrl/user/profile";
  static const String allNotes = "$baseUrl/note?project=";
  static const String createNote = "$baseUrl/note/";
  static const String gallery = "$baseUrl/gallery/";
  static const String payroll = "$baseUrl/payrole";
  // Was hardcoded to one developer's local machine IP ("http://10.10.7.26:5001/"),
  // which only ever worked on that person's LAN — useless for anyone else,
  // and silently broken for every real build. Socket.IO is mounted on the
  // same HTTP server as the REST API (see time-tracker/src/server.ts:
  // `new Server(server, ...)` wraps the same `app.listen(...)` instance),
  // so the correct default is the same host as `liveDomain`, not a separate
  // port. Overridable via `--dart-define=SOCKET_URL=...` for local dev
  // against a backend running elsewhere, without hardcoding anyone's IP.
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: liveDomain,
  );
  static const String breakHours = "$baseUrl/user/break-hours-chart";
  static const String worksHoursSummary =
      "$baseUrl/user/working-hours-summary?date=";
  static const String todayBreakPeriods =
      "$baseUrl/user/todays-break-periods?date=";
  static const String dailySummary = "$baseUrl/timetracker/summary?date=";
  static const String notification = "$baseUrl/notifications";
  static const String notificationMarkAllRead = "$baseUrl/notifications/all";
  static const String notificationMarkReadBase = "$baseUrl/notifications/";
  static const String notificationPreferences = "$baseUrl/notification-preferences";

  // Phase 1 backend (time-tracker/src/app/modules/devicetoken): push-token
  // lifecycle. Deregister takes the token as a path segment, not a body —
  // FCM/APNs tokens never contain '/', so this is a safe single segment.
  static const String deviceRegister = "$baseUrl/devices/register";
  static const String deviceDeregisterBase = "$baseUrl/devices/";

  // Phase 5 backend, never called from mobile before Phase 13. For an
  // EMPLOYEES-role caller both endpoints are always implicitly scoped to
  // the caller's own data (see time-tracker's generateAttendanceReportData/
  // generateMonthlyPdfReport) — an `employee` query param is accepted but
  // ignored for that role, so it's simply omitted here.
  static const String reportMonthly = "$baseUrl/timetracker/reports/monthly";
  static const String reportAttendance = "$baseUrl/timetracker/reports/attendance";
}
