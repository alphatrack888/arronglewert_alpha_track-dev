import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:alpha_track/widgets/app_button/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppButton accepts taps and prevents duplicate actions while loading',
      (tester) async {
    AppSize.size = const Size(375, 882);
    var taps = 0;

    Widget button(bool loading) => MaterialApp(
          home: Scaffold(
            body: AppButton(
              isLoading: loading,
              loadingSize: 24,
              onTap: () => taps++,
              child: const Text('Submit'),
            ),
          ),
        );

    await tester.pumpWidget(button(false));
    await tester.tap(find.text('Submit'));
    expect(taps, 1);

    await tester.pumpWidget(button(true));
    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
    expect(find.text('Submit'), findsNothing);

    await tester.pumpWidget(button(false));
    await tester.tap(find.text('Submit'));
    expect(taps, 2);
  });
}
