import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Session debug breadcrumbs for the iOS blank-screen investigation.
void agentDebugLog(
  String location,
  String message,
  String hypothesisId, [
  Map<String, Object?> data = const {},
]) {
  // #region agent log
  try {
    debugPrint('AGENT_DEBUG [$hypothesisId] $location $message $data');
    final payload = jsonEncode({
      'sessionId': '46932d',
      'runId': 'pre-fix',
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    HttpClient()
        .postUrl(
          Uri.parse(
            'http://127.0.0.1:7728/ingest/feae7a5e-9b3d-491f-8b4a-2604c7f7eef1',
          ),
        )
        .then((req) {
          req.headers.set('Content-Type', 'application/json');
          req.headers.set('X-Debug-Session-Id', '46932d');
          req.add(utf8.encode(payload));
          return req.close();
        })
        .catchError((_) => null);
  } catch (_) {}
  // #endregion
}
