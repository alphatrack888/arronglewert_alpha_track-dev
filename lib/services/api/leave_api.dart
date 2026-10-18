import 'dart:async';
import 'dart:io';

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:dio/dio.dart';

/// POST /leavemanagement without global [ApiServices.apiPostServices] snackbars.
Future<ApiCallResult<void>> postApplyLeave({
  required String companyId,
  required String fromDate,
  required String toDate,
  required String reason,
  required String type,
}) async {
  final body = {
    'company': companyId,
    'from': fromDate,
    'to': toDate,
    'reason': reason,
    'type': type,
  };

  try {
    final response = await ApiServices.instance.api.sendRequest.post(
      ApiUrls.leaveManagement,
      data: body,
    );

    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status >= 200 && status < 300) {
      if (data is Map && data['success'] == true) {
        return ApiCallResult.ok(null);
      }
      return ApiCallResult.fail(
        userMessage: extractApiMessage(data),
        errorCode: extractApiErrorCode(data),
        statusCode: status,
        kind: ApiFailureKind.server,
      );
    }

    return ApiCallResult.fail(
      userMessage: extractApiMessage(data),
      errorCode: extractApiErrorCode(data),
      statusCode: status,
      kind: failureKindFromStatusCode(status),
    );
  } on SocketException catch (e) {
    errorLog('postApplyLeave socket', e);
    return ApiCallResult.fail(kind: ApiFailureKind.network);
  } on TimeoutException catch (e) {
    errorLog('postApplyLeave timeout', e);
    return ApiCallResult.fail(kind: ApiFailureKind.timeout);
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    final message = extractApiMessage(e.response?.data);
    appLog('postApplyLeave DioException status=$status message=$message');
    return ApiCallResult.fail(
      userMessage: message,
      errorCode: extractApiErrorCode(e.response?.data),
      statusCode: status,
      kind: failureKindFromStatusCode(status),
    );
  } catch (e) {
    errorLog('postApplyLeave unexpected', e);
    return ApiCallResult.fail(kind: ApiFailureKind.unknown);
  }
}
