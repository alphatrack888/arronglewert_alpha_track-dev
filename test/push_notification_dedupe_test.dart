// Unit test for PushNotificationService.claimForDisplay — the shared dedupe
// gate that stops the same backend notification from producing two visible
// banners when it arrives over both FCM (foreground onMessage) and the
// existing Socket.IO channel. This is the one piece of Phase 11's new logic
// that's pure enough to unit test without mocking FirebaseMessaging itself
// (which, like the rest of this codebase's service singletons, isn't
// dependency-injected) — permission/token/registration flows genuinely do
// need the real device + Firebase project testing the plan's own exit
// criteria already call for.
import 'package:flutter_test/flutter_test.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';

void main() {
  group('PushNotificationService.claimForDisplay', () {
    test('the first claim for a given notification id succeeds', () {
      final claimed = PushNotificationService.claimForDisplay('notif-a-${DateTime.now().microsecondsSinceEpoch}');
      expect(claimed, isTrue);
    });

    test('a second claim for the same id shortly after is rejected — this is the actual duplicate-banner guard', () {
      final id = 'notif-b-${DateTime.now().microsecondsSinceEpoch}';

      final first = PushNotificationService.claimForDisplay(id);
      final second = PushNotificationService.claimForDisplay(id);

      expect(first, isTrue);
      expect(second, isFalse);
    });

    test('different notification ids never collide with each other', () {
      final idOne = 'notif-c-${DateTime.now().microsecondsSinceEpoch}';
      final idTwo = 'notif-d-${DateTime.now().microsecondsSinceEpoch}';

      expect(PushNotificationService.claimForDisplay(idOne), isTrue);
      expect(PushNotificationService.claimForDisplay(idTwo), isTrue);
    });

    test('a null or empty id always claims true — nothing to dedupe against (e.g. a synthetic socket-only event)', () {
      expect(PushNotificationService.claimForDisplay(null), isTrue);
      expect(PushNotificationService.claimForDisplay(''), isTrue);
      // Calling it again immediately still returns true for empty/null —
      // unlike a real id, these are never recorded as "claimed".
      expect(PushNotificationService.claimForDisplay(null), isTrue);
    });
  });
}
