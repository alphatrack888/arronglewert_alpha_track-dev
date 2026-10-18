import 'dart:async';
import 'dart:io';

import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/api/api_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:dio/dio.dart';

/// POST /timetracker/start without global [ApiServices.apiPostServices] snackbars.
Future<ApiCallResult<String>> postStartTimer({
  required String projectId,
  required double lat,
  required double lng,
}) async {
  final body = {
    'project': projectId,
    'location': {'lat': lat, 'lng': lng},
  };

  try {
    final response = await ApiServices.instance.api.sendRequest.post(
      ApiUrls.startTimer,
      data: body,
    );

    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status >= 200 && status < 300) {
      if (data is Map && data['success'] == true) {
        final sessionPayload = data['data'];
        final sessionId = _parseSessionId(sessionPayload);
        if (sessionId != null && sessionId.isNotEmpty) {
          return ApiCallResult.ok(sessionId);
        }
        appLog('startTimer: success but missing session id in response');
        return ApiCallResult.fail(
          userMessage: extractApiMessage(data),
          statusCode: status,
          kind: ApiFailureKind.server,
        );
      }
      return ApiCallResult.fail(
        userMessage: extractApiMessage(data),
        statusCode: status,
        kind: ApiFailureKind.server,
      );
    }

    return ApiCallResult.fail(
      userMessage: extractApiMessage(data),
      statusCode: status,
      kind: failureKindFromStatusCode(status),
    );
  } on SocketException catch (e) {
    errorLog('startTimer socket', e);
    return ApiCallResult.fail(kind: ApiFailureKind.network);
  } on TimeoutException catch (e) {
    errorLog('startTimer timeout', e);
    return ApiCallResult.fail(kind: ApiFailureKind.timeout);
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    final message = extractApiMessage(e.response?.data);
    appLog('startTimer DioException status=$status message=$message');
    return ApiCallResult.fail(
      userMessage: message,
      statusCode: status,
      kind: failureKindFromStatusCode(status),
    );
  } catch (e) {
    errorLog('startTimer unexpected', e);
    return ApiCallResult.fail(kind: ApiFailureKind.unknown);
  }
}

String? _parseSessionId(dynamic sessionPayload) {
  if (sessionPayload == null) return null;
  if (sessionPayload is! Map) return null;
  final id = sessionPayload['_id'] ?? sessionPayload['id'];
  if (id == null) return null;
  return id.toString();
}
