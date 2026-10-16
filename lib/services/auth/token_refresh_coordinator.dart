import 'package:alpha_track/services/repository/auth_repository/auth_repository.dart';
import 'package:dio/dio.dart';

bool isRefreshTokenRequest(RequestOptions options) {
  return options.uri.path.contains('refresh-token');
}

bool shouldRetryAfterRefresh(RequestOptions options) {
  if (isRefreshTokenRequest(options)) {
    return false;
  }
  if (options.extra['authRetried'] == true) {
    return false;
  }
  final auth = options.headers['Authorization'];
  if (auth == null || auth.toString().isEmpty) {
    return false;
  }
  return true;
}

/// Single-flight refresh so concurrent 401s share one token exchange.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator._();

  static final TokenRefreshCoordinator instance = TokenRefreshCoordinator._();

  static Future<bool>? _inFlight;

  final AuthRepository _authRepository = AuthRepository();

  Future<bool> tryRefresh() {
    _inFlight ??= _authRepository.refreshAccessToken().whenComplete(() {
      _inFlight = null;
    });
    return _inFlight!;
  }
}
