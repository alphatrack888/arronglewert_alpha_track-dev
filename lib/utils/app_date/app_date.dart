import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Locale-aware date formatting.
///
/// Screens used to build dates from hardcoded English month arrays
/// (`['January', ...]`), so dates stayed in English after switching language.
/// These helpers format via `intl` using the active app locale instead, which
/// also gets the per-language ordering right (e.g. "12. März 2026").
///
/// The app's locales are full language names ('german'), so they are mapped to
/// the ISO codes `intl` expects. Locale data is initialised in main().
class AppDate {
  AppDate._();

  static String get _locale {
    switch (Get.locale?.languageCode) {
      case 'german':
        return 'de';
      case 'arabic':
        return 'ar';
      case 'romanian':
        return 'ro';
      default:
        return 'en';
    }
  }

  /// Format with the active locale, falling back to the default locale if
  /// `initializeDateFormatting` has not run for it. Without this guard intl
  /// throws LocaleDataException and takes the whole screen down.
  static String _fmt(DateTime? d, DateFormat Function(String?) build) {
    if (d == null) return '';
    try {
      return build(_locale).format(d);
    } catch (_) {
      return build(null).format(d);
    }
  }

  /// "March 12, 2026" / "12. März 2026"
  static String long(DateTime? d) => _fmt(d, DateFormat.yMMMMd);

  /// "Mar 12, 2026" / "12.03.2026"-ish short form with year.
  static String medium(DateTime? d) => _fmt(d, DateFormat.yMMMd);

  /// "Mar 12" / "12. März"
  static String short(DateTime? d) => _fmt(d, DateFormat.MMMd);

  /// "Mon, Jul 20" / "Mo., 20. Juli"
  static String weekdayShort(DateTime? d) => _fmt(d, DateFormat.MMMEd);

  /// "July 2026" / "Juli 2026"
  static String monthYear(DateTime? d) => _fmt(d, DateFormat.yMMMM);

  /// Uppercased short weekday labels for the active locale, e.g.
  /// en: MON TUE WED … / de: MO DI MI …
  ///
  /// [startMonday] false starts the week on Sunday (calendar grid order).
  /// Trailing dots ("Mo.") are stripped so the labels match the uppercase
  /// eyebrow style used by the charts and calendar.
  static List<String> weekdayLabels({bool startMonday = true}) {
    // 2024-01-01 was a Monday — generate a full week from a known anchor.
    final monday = DateTime(2024, 1, 1);
    final week = List.generate(7, (i) => monday.add(Duration(days: i)));
    final ordered = startMonday ? week : [week[6], ...week.take(6)];
    return ordered
        .map((d) => _fmt(d, DateFormat.E).replaceAll('.', '').toUpperCase())
        .toList();
  }
}
