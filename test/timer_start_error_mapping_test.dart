import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/repository/time_tracker_repository/timer_start_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslation().keys);
    Get.updateLocale(const Locale('english'));
  });

  tearDown(Get.reset);

  group('extractApiMessage', () {
    test('reads top-level message', () {
      expect(
        extractApiMessage({'message': 'Invalid project'}),
        'Invalid project',
      );
    });

    test('reads errorMessages array', () {
      expect(
        extractApiMessage({
          'errorMessages': [
            {'path': '', 'message': 'Failed to upload file'},
          ],
        }),
        'Failed to upload file',
      );
    });
  });

  group('isEmployeeRoleForTimer', () {
    test('employee is allowed', () {
      expect(isEmployeeRoleForTimer('employee'), isTrue);
    });

    test('company is blocked', () {
      expect(isEmployeeRoleForTimer('company'), isFalse);
    });

    test('null role allows attempt', () {
      expect(isEmployeeRoleForTimer(null), isTrue);
    });
  });

  group('timerStartFailureMessage', () {
    test('network uses internet message', () {
      final msg = timerStartFailureMessage(
        ApiCallResult.fail(kind: ApiFailureKind.network),
      );
      expect(msg, contains('Internet'));
    });

    test('forbidden permission uses employee-only copy', () {
      final msg = timerStartFailureMessage(
        ApiCallResult.fail(
          userMessage: "You don't have permission to access this API",
          kind: ApiFailureKind.forbidden,
        ),
      );
      expect(msg, contains('employee'));
    });

    test('server message uses reason template', () {
      final msg = timerStartFailureMessage(
        ApiCallResult.fail(
          userMessage: 'Failed to start timer',
          kind: ApiFailureKind.server,
        ),
      );
      expect(msg, contains('Failed to start timer'));
    });
  });
}
