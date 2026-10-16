import 'package:alpha_track/services/auth/token_refresh_coordinator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

RequestOptions _options({
  required String path,
  Map<String, dynamic>? extra,
  Map<String, dynamic>? headers,
}) {
  return RequestOptions(
    path: path,
    baseUrl: 'https://api.alphatrack.app/api/v1',
    extra: extra ?? {},
    headers: headers ?? {},
  );
}

void main() {
  group('isRefreshTokenRequest', () {
    test('true for refresh-token path', () {
      expect(
        isRefreshTokenRequest(_options(path: '/auth/refresh-token')),
        isTrue,
      );
    });

    test('false for other paths', () {
      expect(
        isRefreshTokenRequest(_options(path: '/user/profile')),
        isFalse,
      );
    });
  });

  group('shouldRetryAfterRefresh', () {
    test('false for refresh-token request', () {
      expect(
        shouldRetryAfterRefresh(_options(path: '/auth/refresh-token')),
        isFalse,
      );
    });

    test('false when already retried', () {
      expect(
        shouldRetryAfterRefresh(
          _options(
            path: '/gallery/',
            extra: {'authRetried': true},
            headers: {'Authorization': 'Bearer x'},
          ),
        ),
        isFalse,
      );
    });

    test('false without Authorization header', () {
      expect(
        shouldRetryAfterRefresh(_options(path: '/gallery/')),
        isFalse,
      );
    });

    test('true for authenticated request not yet retried', () {
      expect(
        shouldRetryAfterRefresh(
          _options(
            path: '/gallery/',
            headers: {'Authorization': 'Bearer x'},
          ),
        ),
        isTrue,
      );
    });
  });
}
