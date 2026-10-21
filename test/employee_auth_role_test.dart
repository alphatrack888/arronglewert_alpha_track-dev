import 'package:alpha_track/services/repository/time_tracker_repository/timer_start_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isEmployeeRoleForAppAuth', () {
    test('returns true only for employee', () {
      expect(isEmployeeRoleForAppAuth('employee'), isTrue);
    });

    test('returns false for company and empty', () {
      expect(isEmployeeRoleForAppAuth('company'), isFalse);
      expect(isEmployeeRoleForAppAuth(null), isFalse);
      expect(isEmployeeRoleForAppAuth(''), isFalse);
    });
  });
}
