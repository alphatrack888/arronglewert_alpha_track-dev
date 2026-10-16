import 'package:alpha_track/services/storage_services/company_id_persistence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shouldFetchLeaveBalance is false for empty company id', () {
    expect(shouldFetchLeaveBalance(''), isFalse);
  });

  test('shouldFetchLeaveBalance is true when company id is set', () {
    expect(shouldFetchLeaveBalance('507f1f77bcf86cd799439011'), isTrue);
  });
}
