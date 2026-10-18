import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

const _leaveApplyErrorCodes = {
  'LEAVE_BALANCE_NOT_CONFIGURED',
  'LEAVE_INSUFFICIENT_BALANCE',
  'LEAVE_INVALID_DATE_RANGE',
  'LEAVE_INVALID_TYPE',
  'LEAVE_CREATE_FAILED',
  'LEAVE_SUBMIT_UNEXPECTED',
  'LEAVE_TYPE_REQUIRED',
  'LEAVE_TYPE_INVALID',
  'LEAVE_FROM_REQUIRED',
  'LEAVE_TO_REQUIRED',
  'LEAVE_VALIDATION_FAILED',
};

/// Maps API [errorCode] to GetX translation key `leaveApplyErr_<CODE>`.
String? _messageFromErrorCode(String? errorCode) {
  if (errorCode == null || errorCode.isEmpty) return null;
  if (!_leaveApplyErrorCodes.contains(errorCode)) return null;
  return 'leaveApplyErr_$errorCode'.tr;
}

/// Pre-errorCode API bodies — map exact English `message` to the same i18n keys.
const Map<String, String> _legacyApiMessageToErrorCode = {
  'Leave balance not found, please try again': 'LEAVE_BALANCE_NOT_CONFIGURED',
  'Your employer has not set up leave allowances yet. Please contact your manager or HR.':
      'LEAVE_BALANCE_NOT_CONFIGURED',
  'You do not have enough leave balance to request this leave':
      'LEAVE_INSUFFICIENT_BALANCE',
  'You do not have enough leave days for this request. Try fewer days or another leave type.':
      'LEAVE_INSUFFICIENT_BALANCE',
  'Invalid leave date range': 'LEAVE_INVALID_DATE_RANGE',
  'Those dates are not valid. The end date must be on or after the start date.':
      'LEAVE_INVALID_DATE_RANGE',
  'Invalid leave type': 'LEAVE_INVALID_TYPE',
  'Failed to create Leavemanagement': 'LEAVE_CREATE_FAILED',
  'Unable to submit leave request. Please try again later.':
      'LEAVE_SUBMIT_UNEXPECTED',
};

String? _messageFromLegacyApiText(String? serverMessage) {
  if (serverMessage == null) return null;
  final code = _legacyApiMessageToErrorCode[serverMessage.trim()];
  if (code == null) return null;
  return _messageFromErrorCode(code);
}

/// Maps a failed apply-leave API result to a localized user message.
String leaveApplyFailureMessage(ApiCallResult<dynamic> result) {
  if (result.success) return '';

  if (kDebugMode && result.errorCode != null) {
    appLog('applyLeave failure errorCode=${result.errorCode}');
  }

  final fromCode = _messageFromErrorCode(result.errorCode);
  if (fromCode != null) return fromCode;

  final fromLegacy = _messageFromLegacyApiText(result.userMessage);
  if (fromLegacy != null) return fromLegacy;

  switch (result.kind) {
    case ApiFailureKind.network:
      return 'checkInternetTitle'.tr;
    case ApiFailureKind.timeout:
      return 'leaveApplicationTimeout'.tr;
    case ApiFailureKind.unauthorized:
      return 'leaveApplyErr_SESSION_EXPIRED'.tr;
    case ApiFailureKind.forbidden:
      return 'leaveApplicationFailed'.tr;
    case ApiFailureKind.validation:
    case ApiFailureKind.server:
      if (result.userMessage != null &&
          isSafeServerMessage(result.userMessage!)) {
        return result.userMessage!;
      }
      return result.kind == ApiFailureKind.server
          ? 'leaveApplicationServerError'.tr
          : 'leaveApplicationFailed'.tr;
    case ApiFailureKind.unknown:
    case null:
      return 'leaveApplicationFailed'.tr;
  }
}
