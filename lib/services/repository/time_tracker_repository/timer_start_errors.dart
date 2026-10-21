import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:get/get.dart';

/// Maps a failed start-timer API result to a localized user message.
/// [serverMessageSuffix] is used with timerStartFailedWithReason when showing
/// raw API text (pass translated template from caller if needed).
String timerStartFailureMessage(
  ApiCallResult<dynamic> result, {
  String Function(String reason)? formatWithReason,
}) {
  if (result.success) return '';

  switch (result.kind) {
    case ApiFailureKind.network:
      return 'checkInternetTitle'.tr;
    case ApiFailureKind.timeout:
      return 'timerStartTimeout'.tr;
    case ApiFailureKind.unauthorized:
      return 'sessionExpiredStartTimer'.tr;
    case ApiFailureKind.forbidden:
      return _forbiddenMessage(result.userMessage);
    case ApiFailureKind.validation:
    case ApiFailureKind.server:
    case ApiFailureKind.unknown:
    case null:
      return _messageWithOptionalServerText(
        result.userMessage,
        formatWithReason: formatWithReason,
      );
  }
}

String _forbiddenMessage(String? serverMessage) {
  final lower = serverMessage?.toLowerCase() ?? '';
  if (lower.contains('permission') || lower.contains('authorized')) {
    return 'timerStartEmployeeOnly'.tr;
  }
  if (serverMessage != null && isSafeServerMessage(serverMessage)) {
    return serverMessage;
  }
  return 'timerStartEmployeeOnly'.tr;
}

String _messageWithOptionalServerText(
  String? serverMessage, {
  String Function(String reason)? formatWithReason,
}) {
  if (serverMessage != null && isSafeServerMessage(serverMessage)) {
    if (formatWithReason != null) {
      return formatWithReason(serverMessage);
    }
    return 'timerStartFailedWithReason'.trParams({'reason': serverMessage});
  }
  return 'timerStartFailed'.tr;
}

/// Pre-API: non-employee roles cannot use /timetracker/start.
bool isEmployeeRoleForTimer(String? role) {
  if (role == null || role.isEmpty) return true;
  return role == 'employee';
}

/// Mobile app sign-in and session: only employee accounts are supported.
bool isEmployeeRoleForAppAuth(String? role) {
  if (role == null || role.isEmpty) return false;
  return role == 'employee';
}
