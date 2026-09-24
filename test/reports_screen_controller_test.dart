// Unit test for ReportsScreenController.isValidRange — the guard that stops
// generateReport() from calling the attendance endpoint with an inverted
// date range (same class of edge case Phase 8/10 already guard against on
// the web side). Doesn't need GetX bootstrapping or a real ReportRepository
// call: the controller can be instantiated directly since Rx fields don't
// require DI, and onInit() only fires through Get.put/Get.find, not a bare
// constructor call.
import 'package:flutter_test/flutter_test.dart';
import 'package:alpha_track/screens/reports_screen/controller/reports_screen_controller.dart';

void main() {
  group('ReportsScreenController.isValidRange', () {
    test('a range where end is after start is valid', () {
      final controller = ReportsScreenController();
      controller.startDate.value = DateTime(2026, 3, 1);
      controller.endDate.value = DateTime(2026, 3, 10);

      expect(controller.isValidRange, isTrue);
    });

    test('a same-day range is valid', () {
      final controller = ReportsScreenController();
      final day = DateTime(2026, 3, 5);
      controller.startDate.value = day;
      controller.endDate.value = day;

      expect(controller.isValidRange, isTrue);
    });

    test('an inverted range (end before start) is invalid', () {
      final controller = ReportsScreenController();
      controller.startDate.value = DateTime(2026, 3, 10);
      controller.endDate.value = DateTime(2026, 3, 1);

      expect(controller.isValidRange, isFalse);
    });
  });
}
