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

/// A session the server still has open (`active` or `paused`).
class OpenTimeSession {
  const OpenTimeSession({
    required this.id,
    required this.status,
    required this.elapsedMs,
    this.projectId,
    this.projectTitle,
    this.pauseStartedAt,
  });

  final String id;
  final String status;
  final int elapsedMs;
  final String? projectId;
  final String? projectTitle;
  final DateTime? pauseStartedAt;

  static OpenTimeSession? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    if (id is! String || id.isEmpty) return null;
    final status = raw['status'];
    final elapsed = raw['elapsedMs'];
    final project = raw['project'];
    String? projectId;
    String? projectTitle;
    if (project is Map) {
      final parsedId = project['id'];
      final parsedTitle = project['title'];
      if (parsedId is String && parsedId.isNotEmpty) projectId = parsedId;
      if (parsedTitle is String && parsedTitle.isNotEmpty) {
        projectTitle = parsedTitle;
      }
    }
    final rawPauseStart = raw['pauseStartedAt'];
    return OpenTimeSession(
      id: id,
      status: status is String ? status : 'active',
      elapsedMs: elapsed is num ? elapsed.round() : 0,
      projectId: projectId,
      projectTitle: projectTitle,
      pauseStartedAt: rawPauseStart is String
          ? DateTime.tryParse(rawPauseStart)
          : null,
    );
  }
}

/// GET /timetracker/open. Null when the request fails so the caller can
/// keep the locally saved timer. An empty list means nothing is open.
Future<List<OpenTimeSession>?> fetchOpenSessions() async {
  try {
    final response = await ApiServices.instance.api.sendRequest.get(
      ApiUrls.openSessions,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status < 200 || status >= 300 || data is! Map || data['success'] != true) {
      return null;
    }
    final raw = data['data'];
    if (raw is! List) return [];
    return raw.map(OpenTimeSession.fromJson).whereType<OpenTimeSession>().toList();
  } catch (e) {
    errorLog('fetchOpenSessions', e);
    return null;
  }
}

String? _parseSessionId(dynamic sessionPayload) {
  if (sessionPayload == null) return null;
  if (sessionPayload is! Map) return null;
  final id = sessionPayload['_id'] ?? sessionPayload['id'];
  if (id == null) return null;
  return id.toString();
}
