import 'package:alpha_track/widgets/ds/ds_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets(
    'DsDialog action buttons stay tappable when a long body would otherwise '
    'overflow a small screen',
    (tester) async {
      // Small viewport + long body = the exact condition that used to push the
      // buttons into the clipped, un-hit-testable region below the dialog.
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var confirmed = false;
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DsDialog(
                title: 'Location Access Required',
                tone: DsDialogTone.info,
                icon: LucideIcons.mapPin,
                confirmLabel: 'Allow',
                cancelLabel: 'Deny',
                onConfirm: () => confirmed = true,
                onCancel: () => cancelled = true,
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alpha Track collects your location data to:'),
                    SizedBox(height: 12),
                    Text('Verify your on-site attendance and work location '
                        'for project tracking.'),
                    Text('Record your location when you start and stop work '
                        'sessions.'),
                    Text('Track location in the background during active work '
                        'sessions to confirm job-site presence.'),
                    SizedBox(height: 12),
                    Text('Your location data is sent to our servers and used '
                        'solely for attendance and project management purposes. '
                        'Location tracking is only active during your work '
                        'sessions.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Deny'), findsOneWidget);

      // These taps throw if the target isn't hit-testable (i.e. off-screen or
      // clipped) — which is exactly the bug we're guarding against.
      await tester.tap(find.text('Deny'));
      await tester.tap(find.text('Allow'));
      await tester.pump();

      expect(cancelled, isTrue, reason: 'Deny button did not fire');
      expect(confirmed, isTrue, reason: 'Allow button did not fire');
    },
  );
}
