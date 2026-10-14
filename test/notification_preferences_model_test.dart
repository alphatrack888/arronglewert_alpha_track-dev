import 'package:alpha_track/screens/notification_preferences_screen/models/notification_preferences_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NotificationPreferences round-trip fromJson/toJson', () {
    const json = {
      'pushEnabled': false,
      'categories': {
        'leave': true,
        'project': false,
        'payroll': true,
        'overtime': false,
        'attendance': true,
        'subscription': false,
      },
      'digestMode': 'daily',
      'language': 'de',
    };

    final prefs = NotificationPreferences.fromJson(json);
    expect(prefs.pushEnabled, false);
    expect(prefs.categories.project, false);
    expect(prefs.digestMode, 'daily');
    expect(prefs.language, 'de');
    expect(prefs.toJson(), json);
  });
}
