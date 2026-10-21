import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';

/// Local clock hour (0–24) for a UTC instant.
double localHourOfDay(DateTime instant) {
  final local = instant.toLocal();
  return local.hour + local.minute / 60.0 + local.second / 3600.0;
}

/// Worked intervals in local hours. Empty when there are no sessions.
/// A session that crosses local midnight is drawn through 24:00.
List<List<double>> workIntervalsLocal(
  List<Session> sessions, {
  DateTime? now,
}) {
  final intervals = <List<double>>[];
  for (final session in sessions) {
    final start = session.startTime;
    if (start == null) continue;
    final end = session.endTime ?? now ?? DateTime.now();
    final startLocal = start.toLocal();
    final endLocal = end.toLocal();
    final startDay = DateTime(startLocal.year, startLocal.month, startLocal.day);
    final endDay = DateTime(endLocal.year, endLocal.month, endLocal.day);
    final a = localHourOfDay(start);
    var b = localHourOfDay(end);
    if (endDay.isAfter(startDay)) b = 24;
    if (b > a) intervals.add([a, b]);
  }
  intervals.sort((x, y) => x[0].compareTo(y[0]));
  return intervals;
}

/// Bar fill. Zero when nothing in the breakdown is above zero.
double breakdownFraction(double value, double maxValue) {
  if (maxValue <= 0) return 0;
  final fraction = value / maxValue;
  if (fraction < 0) return 0;
  if (fraction > 1) return 1;
  return fraction;
}

/// `YYYY-MM-DD` of a session's stored date field.
///
/// Date-only strings parse as local midnight, so converting them with
/// `toUtc()` would move the key to the previous UTC day in positive offsets.
/// The calendar fields on the parsed value are the stored day.
String storedDateKey(DateTime? date) {
  if (date == null) return '';
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime utcDay(DateTime selected) {
  final utc = selected.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

/// Monday of the UTC week that contains [selected], as `YYYY-MM-DD`.
String utcMondayKey(DateTime selected) {
  final day = utcDay(selected);
  return utcDateKey(day.subtract(Duration(days: day.weekday - 1)));
}

/// First day of the UTC month that contains [selected].
String utcMonthStartKey(DateTime selected) {
  final day = utcDay(selected);
  return utcDateKey(DateTime.utc(day.year, day.month, 1));
}

class WorkedBar {
  const WorkedBar(this.date, this.hours);

  final String date;
  final double hours;
}

/// Worked hours per project id, from `totalTime` milliseconds.
Map<String, double> hoursByProject(List<Session> sessions) {
  final totals = <String, double>{};
  for (final session in sessions) {
    final id = session.project?.id;
    if (id == null || id.isEmpty) continue;
    totals[id] = (totals[id] ?? 0) + ((session.totalTime ?? 0) / 3600000);
  }
  return totals;
}

/// One bar per UTC date from [from] through [to], grouped by stored `date`.
List<WorkedBar> workedBarsForRange(
  List<Session> sessions,
  String from,
  String to,
) {
  final totals = <String, double>{};
  for (final session in sessions) {
    final key = storedDateKey(session.date);
    if (key.isEmpty) continue;
    totals[key] = (totals[key] ?? 0) + ((session.totalTime ?? 0) / 3600000);
  }

  final bars = <WorkedBar>[];
  var cursor = DateTime.parse('${from}T00:00:00.000Z');
  final end = DateTime.parse('${to}T00:00:00.000Z');
  while (!cursor.isAfter(end)) {
    final key = utcDateKey(cursor);
    bars.add(WorkedBar(key, totals[key] ?? 0));
    cursor = cursor.add(const Duration(days: 1));
  }
  return bars;
}
