import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/ds/ds_bottom_sheet.dart';
import 'package:alpha_track/widgets/getx_observer/getx_custome_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Mirrors Apply Leave sheet: Builder + dsPop on Cancel (not Get.back).
void main() {
  testWidgets('DsBottomSheet Cancel via dsPop closes the sheet', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [NavigationObserver()],
        useInheritedMediaQuery: true,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                DsBottomSheet.show(
                  Builder(
                    builder: (sheetContext) {
                      return DsBottomSheet(
                        title: 'Apply Leave',
                        trailing: GestureDetector(
                          onTap: () => dsPop(sheetContext),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: Text('Cancel'),
                          ),
                        ),
                        child: const Text('sheet body'),
                      );
                    },
                  ),
                );
              },
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('sheet body'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('sheet body'), findsNothing);
    expect(find.text('OPEN'), findsOneWidget);
  });

  testWidgets(
      'tall DsBottomSheet with keyboard viewInsets does not overflow',
      (tester) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [NavigationObserver()],
        useInheritedMediaQuery: true,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                DsBottomSheet.show(
                  Builder(
                    builder: (sheetContext) {
                      return DsBottomSheet(
                        title: 'Apply Leave',
                        trailing: GestureDetector(
                          onTap: () => dsPop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 240),
                              const TextField(maxLines: 4),
                              const SizedBox(height: 20),
                              const Text('apply-button'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text('OPEN'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('apply-button'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN'), findsOneWidget);
  });
}
