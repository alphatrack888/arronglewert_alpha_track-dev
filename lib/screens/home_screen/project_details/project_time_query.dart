import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart';

/// UTC calendar day used by the API when writing [TimeSession.date]
/// (`now.toISOString().split('T')[0]`).
String utcDateKey([DateTime? now]) {
  final utc = (now ?? DateTime.now()).toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

List<Session> sortedSessionsByStartDesc(List<Session>? sessions) {
  final list = List<Session>.from(sessions ?? const <Session>[]);
  list.sort((a, b) =>
      (b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0)));
  return list;
}

/// UI kind for the Time Tracker session list. Failed fetch is never "empty".
enum TimeTrackerListKind { loading, error, empty, list }

TimeTrackerListKind timeTrackerListKind({
  required bool loading,
  required bool error,
  required int sessionCount,
}) {
  if (error) return TimeTrackerListKind.error;
  if (loading && sessionCount == 0) return TimeTrackerListKind.loading;
  if (sessionCount == 0) return TimeTrackerListKind.empty;
  return TimeTrackerListKind.list;
}
