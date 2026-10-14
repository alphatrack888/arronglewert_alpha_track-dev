import 'dart:io';

import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/utils/app_string/app_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Verifies the localization pipeline itself works, and guards against the
/// regression where redesigned screens hardcode English instead of using .tr.
void main() {
  testWidgets('switching locale to german translates .tr strings',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: const Locale('english'),
        fallbackLocale: const Locale('english'),
        home: Scaffold(
          body: Builder(
            builder: (_) => Text(AppString.contactNumber.tr),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contact Number'), findsOneWidget);

    Get.updateLocale(const Locale('german'));
    await tester.pumpAndSettle();

    expect(find.text('Telefonnummer'), findsOneWidget,
        reason: 'german locale must resolve via AppTranslation');
    expect(find.text('Contact Number'), findsNothing);
  });

  test('every "key".tr used in lib/ exists in the english map', () {
    final english = AppTranslation().keys['english']!;
    // Matches a string literal immediately followed by .tr — e.g. 'seeAll'.tr
    final usage = RegExp(r"'([A-Za-z][A-Za-z0-9_]*)'\s*\.tr\b");
    final missing = <String, Set<String>>{};

    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      for (final m in usage.allMatches(f.readAsStringSync())) {
        final key = m.group(1)!;
        if (!english.containsKey(key)) {
          missing.putIfAbsent(f.path, () => <String>{}).add(key);
        }
      }
    }

    expect(missing, isEmpty,
        reason: 'these .tr keys have no translation entry (they would render '
            'as the raw key): $missing');
  });

  test('every locale defines the same keys as english', () {
    final keys = AppTranslation().keys;
    final english = keys['english']!.keys.toSet();

    for (final locale in ['german', 'arabic', 'romanian']) {
      final missing = english.difference(keys[locale]!.keys.toSet());
      expect(missing, isEmpty,
          reason: '$locale is missing ${missing.length} keys: '
              '${missing.take(20).join(', ')}');
    }
  });
}
