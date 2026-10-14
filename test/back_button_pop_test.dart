import 'package:alpha_track/widgets/ds/ds_back_button.dart';
import 'package:alpha_track/widgets/getx_observer/getx_custome_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Regression tests for the recurring "Back is not working" TestFlight reports.
///
/// Root cause: `Get.back()` resolves the navigator through GetX's *global* key
/// and silently no-ops when that key's `currentState` is detached. [dsPop] pops
/// through the widget's own `context`, which cannot desync.
void main() {
  Widget app({required Widget second, GlobalKey<NavigatorState>? navKey}) =>
      GetMaterialApp(
        navigatorObservers: [NavigationObserver()],
        useInheritedMediaQuery: true,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
        initialRoute: '/first',
        navigatorKey: navKey,
        getPages: [
          GetPage(
            name: '/first',
            page: () => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/second'),
                  child: const Text('GO'),
                ),
              ),
            ),
          ),
          GetPage(
            name: '/second',
            page: () => second,
            transition: Transition.rightToLeftWithFade,
          ),
        ],
      );

  Widget screenWithDsBack() => Scaffold(
        body: SafeArea(
          child: Column(
            children: const [
              Row(children: [DsBackButton(), SizedBox(width: 12), Text('Second')]),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      );

  Future<void> pushSecond(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.text('GO'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
  }

  testWidgets('DsBackButton pops the route', (tester) async {
    await tester.pumpWidget(app(second: screenWithDsBack()));
    await pushSecond(tester);

    await tester.tap(find.byIcon(LucideIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text('Second'), findsNothing);
    expect(find.text('GO'), findsOneWidget);
  });

  testWidgets(
      'DsBackButton still pops when GetX global key is detached '
      '(the case where Get.back() silently no-ops)', (tester) async {
    // Detach Get.key from the live navigator by giving the app a *different*
    // navigator key. Get.key.currentState is now null, so Get.back() would be a
    // no-op — dsPop must still pop via context.
    final otherKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(app(second: screenWithDsBack(), navKey: otherKey));
    await pushSecond(tester);

    await tester.tap(find.byIcon(LucideIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text('Second'), findsNothing,
        reason: 'dsPop must pop through context, not the global Get key');
    expect(find.text('GO'), findsOneWidget);
  });
}
