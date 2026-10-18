import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/services/api/api_call_result.dart';
import 'package:alpha_track/services/repository/leave_management_repository/leave_apply_errors.dart';
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

  group('extractApiErrorCode', () {
    test('reads top-level errorCode', () {
      expect(
        extractApiErrorCode({
          'success': false,
          'errorCode': 'LEAVE_BALANCE_NOT_CONFIGURED',
        }),
        'LEAVE_BALANCE_NOT_CONFIGURED',
      );
    });
  });

  group('leaveApplyFailureMessage', () {
    test('network uses internet message', () {
      final msg = leaveApplyFailureMessage(
        ApiCallResult.fail(kind: ApiFailureKind.network),
      );
      expect(msg, contains('Internet'));
    });

    test('timeout uses leave timeout copy', () {
      final msg = leaveApplyFailureMessage(
        ApiCallResult.fail(kind: ApiFailureKind.timeout),
      );
      expect(msg, contains('timed out'));
    });

    test('errorCode LEAVE_BALANCE_NOT_CONFIGURED uses friendly copy', () {
      final msg = leaveApplyFailureMessage(
        ApiCallResult.fail(
          errorCode: 'LEAVE_BALANCE_NOT_CONFIGURED',
          kind: ApiFailureKind.validation,
        ),
      );
      expect(msg, contains('employer'));
      expect(msg, contains('HR'));
      expect(msg, isNot(contains('Could not submit leave')));
    });

    test('legacy API message maps to same friendly copy', () {
      final msg = leaveApplyFailureMessage(
        ApiCallResult.fail(
          userMessage: 'Leave balance not found, please try again',
          kind: ApiFailureKind.validation,
          statusCode: 404,
        ),
      );
      expect(msg, contains('employer'));
    });

    test('unknown code falls back to generic', () {
      final msg = leaveApplyFailureMessage(
        ApiCallResult.fail(
          errorCode: 'LEAVE_UNKNOWN_FUTURE_CODE',
          kind: ApiFailureKind.unknown,
        ),
      );
      expect(msg, contains('Failed to submit'));
    });

    test('server without code uses generic server copy', () {
      final msg = leaveApplyFailureMessage(
        ApiCallResult.fail(
          kind: ApiFailureKind.server,
          statusCode: 500,
        ),
      );
      expect(msg, contains('Something went wrong'));
    });
  });
}
