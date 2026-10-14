import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/screens/break_screen/history_screens.dart';
import 'package:alpha_track/widgets/getx_observer/getx_custome_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Pump the REAL LeaveHistoryScreen behind a first route and tap its real
/// header back button. Mirrors main.dart's GetMaterialApp config.
void main() {
  // LeaveHistoryScreen formats dates via AppDate/intl, which needs locale data.
  setUpAll(() async => initializeDateFormatting());

  testWidgets('LeaveHistoryScreen header back button pops', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: const Locale('english'),
        fallbackLocale: const Locale('english'),
        navigatorObservers: [NavigationObserver()],
        useInheritedMediaQuery: true,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
        initialRoute: '/first',
        navigatorKey: Get.key,
        getPages: [
          GetPage(
            name: '/first',
            page: () => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/history'),
                  child: const Text('GO'),
                ),
              ),
            ),
          ),
          GetPage(
            name: '/history',
            page: () => const LeaveHistoryScreen(),
            transition: Transition.rightToLeftWithFade,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('GO'));
    await tester.pumpAndSettle();

    expect(find.text('leaveHistory'.tr), findsOneWidget,
        reason: 'history route should be pushed');

    final back = find.byIcon(LucideIcons.arrowLeft);
    expect(back, findsOneWidget, reason: 'back arrow should be present');

    await tester.tap(back);
    await tester.pumpAndSettle();

    expect(find.text('leaveHistory'.tr), findsNothing,
        reason: 'back button should have popped Leave History');
    expect(find.text('GO'), findsOneWidget);
  });
}
