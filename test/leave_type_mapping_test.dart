import 'package:alpha_track/screens/break_screen/leave_screen/leave_type_display.dart';
import 'package:alpha_track/screens/break_screen/leave_screen/leave_type_mapping.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('leaveTypeKeyToApi', () {
    test('maps four picker keys to valid API types', () {
      const keys = [
        AppString.sickLeave,
        AppString.casualLeave,
        AppString.earnLeave,
        AppString.withoutPayleave,
      ];
      for (final key in keys) {
        final api = leaveTypeKeyToApi(key);
        expect(isValidLeaveApiType(api), isTrue, reason: '$key -> $api');
        expect(api, isNot('annual'), reason: 'never send invalid annual type');
      }
    });

    test('maps sick, casual, earn, wp', () {
      expect(leaveTypeKeyToApi(AppString.sickLeave), 'sick');
      expect(leaveTypeKeyToApi(AppString.casualLeave), 'casual');
      expect(leaveTypeKeyToApi(AppString.earnLeave), 'earn');
      expect(leaveTypeKeyToApi(AppString.withoutPayleave), 'wp');
    });

    test('unknown key falls back to casual', () {
      expect(leaveTypeKeyToApi('unknown'), 'casual');
    });
  });

  group('normalizeLeaveApiType', () {
    test('accepts API codes', () {
      expect(normalizeLeaveApiType('earn'), 'earn');
    });

    test('maps legacy English balance labels', () {
      expect(normalizeLeaveApiType('Earn Leave'), 'earn');
      expect(normalizeLeaveApiType('Sick Leave'), 'sick');
    });
  });
}
