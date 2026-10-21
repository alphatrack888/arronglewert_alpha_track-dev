import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('utcDateKey', () {
    test('formats the UTC calendar day as YYYY-MM-DD', () {
      expect(
        utcDateKey(DateTime.utc(2026, 10, 19, 22, 30)),
        '2026-10-19',
      );
    });

    test('converts local evening in UTC+6 to the previous UTC date', () {
      final local = DateTime(2026, 10, 20, 2, 0); // interpreted as local
      final key = utcDateKey(local);
      final utc = local.toUtc();
      final expected =
          '${utc.year.toString().padLeft(4, '0')}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
      expect(key, expected);
      expect(key.contains('-'), isTrue);
      expect(key.length, 10);
    });
  });

  group('sortedSessionsByStartDesc', () {
    test('orders newest startTime first', () {
      final older = Session(id: 'a', startTime: DateTime.utc(2026, 10, 19, 8));
      final newer = Session(id: 'b', startTime: DateTime.utc(2026, 10, 19, 12));
      final sorted = sortedSessionsByStartDesc([older, newer]);
      expect(sorted.map((s) => s.id).toList(), ['b', 'a']);
    });
  });

  group('timeTrackerListKind', () {
    test('failed fetch is error, not empty', () {
      expect(
        timeTrackerListKind(loading: false, error: true, sessionCount: 0),
        TimeTrackerListKind.error,
      );
    });

    test('200 with no sessions is empty', () {
      expect(
        timeTrackerListKind(loading: false, error: false, sessionCount: 0),
        TimeTrackerListKind.empty,
      );
    });

    test('200 with sessions is list even while a background reload is in flight', () {
      expect(
        timeTrackerListKind(loading: true, error: false, sessionCount: 1),
        TimeTrackerListKind.list,
      );
    });

    test('first load with no data is loading', () {
      expect(
        timeTrackerListKind(loading: true, error: false, sessionCount: 0),
        TimeTrackerListKind.loading,
      );
    });
  });
}
