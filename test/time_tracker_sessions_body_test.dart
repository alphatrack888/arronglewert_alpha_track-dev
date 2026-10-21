import 'package:alpha_track/core/app_translation/app_translation.dart';
import 'package:alpha_track/screens/home_screen/project_details/project_time_query.dart';
import 'package:alpha_track/screens/home_screen/project_details/time_tracker_sessions_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Widget app(Widget child) => GetMaterialApp(
        translations: AppTranslation(),
        locale: const Locale('english'),
        fallbackLocale: const Locale('english'),
        home: Scaffold(body: child),
      );

  testWidgets('error state shows Retry, not the empty copy', (tester) async {
    await tester.pumpWidget(app(
      TimeTrackerSessionsBody(
        kind: TimeTrackerListKind.error,
        onRetry: () {},
        empty: const Text('noSessionsYet'),
        children: const [Text('session-card')],
      ),
    ));

    expect(find.text('retry'.tr), findsWidgets);
    expect(find.text('noSessionsYet'), findsNothing);
    expect(find.text('session-card'), findsNothing);
  });

  testWidgets('empty 200 shows empty widget, not Retry', (tester) async {
    await tester.pumpWidget(app(
      TimeTrackerSessionsBody(
        kind: TimeTrackerListKind.empty,
        onRetry: () {},
        empty: const Text('noSessionsYet'),
        children: const [Text('session-card')],
      ),
    ));

    expect(find.text('noSessionsYet'), findsOneWidget);
    expect(find.text('retry'.tr), findsNothing);
    expect(find.text('session-card'), findsNothing);
  });

  testWidgets('list kind renders session cards', (tester) async {
    await tester.pumpWidget(app(
      TimeTrackerSessionsBody(
        kind: TimeTrackerListKind.list,
        onRetry: () {},
        empty: const Text('noSessionsYet'),
        children: const [Text('session-card')],
      ),
    ));

    expect(find.text('session-card'), findsOneWidget);
    expect(find.text('noSessionsYet'), findsNothing);
  });

  testWidgets('loading kind shows a progress indicator', (tester) async {
    await tester.pumpWidget(app(
      TimeTrackerSessionsBody(
        kind: TimeTrackerListKind.loading,
        onRetry: () {},
        empty: const Text('noSessionsYet'),
        children: const [Text('session-card')],
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('session-card'), findsNothing);
  });
}
