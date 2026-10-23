import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/report_screen/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty sessions produce no day-chart intervals', () {
    expect(workIntervalsLocal(const []), isEmpty);
  });

  test('local clock comes from the instant converted to local time', () {
    final instant = DateTime.utc(2026, 1, 10, 3, 30);
    final local = instant.toLocal();
    expect(
      localHourOfDay(instant),
      closeTo(local.hour + local.minute / 60.0 + local.second / 3600.0, 0.0001),
    );
  });

  test('breakdown fraction is zero when every value is zero', () {
    expect(breakdownFraction(0, 0), 0);
  });

  test('breakdown fraction is proportional to the largest value', () {
    expect(breakdownFraction(2, 8), 0.25);
    expect(breakdownFraction(8, 8), 1);
  });

  test('hours group by project id from totalTime', () {
    final sessions = [
      Session(project: Project(id: 'a'), totalTime: 2 * 60 * 60 * 1000),
      Session(project: Project(id: 'a'), totalTime: 30 * 60 * 1000),
      Session(project: Project(id: 'b'), totalTime: 60 * 60 * 1000),
      Session(totalTime: 60 * 60 * 1000),
    ];

    final hours = hoursByProject(sessions);

    expect(hours['a'], closeTo(2.5, 0.0001));
    expect(hours['b'], closeTo(1, 0.0001));
    expect(hours.containsKey(''), isFalse);
    expect(hours.length, 2);
  });

  test('week bars stay on the stored UTC date, not the local next day', () {
    final session = Session(
      date: DateTime.parse('2026-01-10'),
      startTime: DateTime.parse('2026-01-10T23:00:00.000Z'),
      totalTime: 60 * 60 * 1000,
    );

    final bars = workedBarsForRange([session], '2026-01-10', '2026-01-11');

    expect(bars, hasLength(2));
    expect(bars[0].date, '2026-01-10');
    expect(bars[0].hours, 1);
    expect(bars[1].date, '2026-01-11');
    expect(bars[1].hours, 0);
  });

  test('a short day labels every hour', () {
    expect(hourAxisTicks(14.1, 17), [14, 15, 16, 17]);
  });

  test('a half day labels every two hours', () {
    expect(hourAxisTicks(0, 12), [0, 2, 4, 6, 8, 10, 12]);
  });

  test('a full day labels every six hours', () {
    expect(hourAxisTicks(0, 24), [0, 6, 12, 18, 24]);
  });

  test('a tick that would sit on the last hour is dropped', () {
    expect(hourAxisTicks(9, 16), [9, 11, 13, 16]);
  });
}
