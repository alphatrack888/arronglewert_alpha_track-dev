/// Result of a single API call without showing UI side effects.
enum ApiFailureKind {
  network,
  timeout,
  unauthorized,
  forbidden,
  validation,
  server,
  unknown,
}

class ApiCallResult<T> {
  const ApiCallResult._({
    required this.success,
    this.data,
    this.userMessage,
    this.errorCode,
    this.statusCode,
    this.kind,
  });

  final bool success;
  final T? data;
  final String? userMessage;
  final String? errorCode;
  final int? statusCode;
  final ApiFailureKind? kind;

  factory ApiCallResult.ok(T data) =>
      ApiCallResult._(success: true, data: data);

  factory ApiCallResult.fail({
    String? userMessage,
    String? errorCode,
    int? statusCode,
    ApiFailureKind kind = ApiFailureKind.unknown,
  }) =>
      ApiCallResult._(
        success: false,
        userMessage: userMessage,
        errorCode: errorCode,
        statusCode: statusCode,
        kind: kind,
      );
}

/// Stable API error code from time-tracker error JSON (e.g. LEAVE_BALANCE_NOT_CONFIGURED).
String? extractApiErrorCode(dynamic data) {
  if (data == null || data is! Map) return null;
  final code = data['errorCode'];
  if (code is String && code.trim().isNotEmpty) {
    return code.trim();
  }
  return null;
}

/// Pulls a human-readable message from time-tracker error JSON bodies.
String? extractApiMessage(dynamic data) {
  if (data == null) return null;
  if (data is String && data.isNotEmpty) return data;
  if (data is! Map) return null;

  final message = data['message'];
  if (message is String && message.trim().isNotEmpty) {
    return message.trim();
  }

  final errorMessages = data['errorMessages'];
  if (errorMessages is List && errorMessages.isNotEmpty) {
    final first = errorMessages.first;
    if (first is Map) {
      final nested = first['message'];
      if (nested is String && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }
  }
  return null;
}

ApiFailureKind failureKindFromStatusCode(int? statusCode) {
  if (statusCode == null) return ApiFailureKind.unknown;
  if (statusCode == 401) return ApiFailureKind.unauthorized;
  if (statusCode == 403) return ApiFailureKind.forbidden;
  if (statusCode == 400 || statusCode == 422) return ApiFailureKind.validation;
  if (statusCode >= 500) return ApiFailureKind.server;
  return ApiFailureKind.unknown;
}

/// Whether API error text is safe to show in a snackbar (length, non-empty).
bool isSafeServerMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty || trimmed.length > 200) return false;
  return true;
}
