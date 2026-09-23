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
  static const String socketUrl = "http://10.10.7.26:5001/";
  static const String breakHours = "$baseUrl/user/break-hours-chart";
  static const String worksHoursSummary =
      "$baseUrl/user/working-hours-summary?date=";
  static const String todayBreakPeriods =
      "$baseUrl/user/todays-break-periods?date=";
  static const String dailySummary = "$baseUrl/timetracker/summary?date=";
  static const String notification = "$baseUrl/notifications";
}
