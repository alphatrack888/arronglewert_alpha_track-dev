import 'package:alpha_track/screens/notification_screen/notification_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const translations = {
    'translations': {
      'english': {'title': 'English title', 'body': 'English body'},
      'german': {'title': 'German title', 'body': 'German body'},
      'arabic': {'title': 'Arabic title', 'body': 'Arabic body'},
      'romanian': {'title': 'Romanian title', 'body': 'Romanian body'},
    },
    'title': 'Stored title',
    'body': 'Stored body',
  };

  test('uses the saved language when that sentence exists', () {
    final result = NotificationLocale.apply(translations, 'arabic');
    expect(result['title'], 'Arabic title');
    expect(result['body'], 'Arabic body');
  });

  test('uses English when the language is missing or unknown', () {
    final missing = NotificationLocale.apply(
      {
        'translations': {
          'english': {'title': 'English title', 'body': 'English body'},
        },
        'title': 'Stored title',
        'body': 'Stored body',
      },
      'german',
    );
    final unknown = NotificationLocale.apply(translations, 'french');

    expect(missing['title'], 'English title');
    expect(unknown['title'], 'English title');
    expect(NotificationLocale.normalize(null), 'english');
  });

  test('keeps the stored sentence when no translations were saved', () {
    final result = NotificationLocale.apply(
      {'title': 'Stored German', 'body': 'Gespeichert'},
      'arabic',
    );
    expect(result['title'], 'Stored German');
    expect(result['body'], 'Gespeichert');
  });
}
