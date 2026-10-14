import 'package:flutter_test/flutter_test.dart';
import 'package:alpha_track/services/push_notification_service/push_notification_service.dart';

void main() {
  group('PushNotificationService.claimForDisplay', () {
    test('the first claim for a given notification id succeeds', () {
      final claimed = PushNotificationService.claimForDisplay(
        'notif-a-${DateTime.now().microsecondsSinceEpoch}',
      );
      expect(claimed, isTrue);
    });

    test('a second claim for the same id shortly after is rejected', () {
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

    test('null or empty id always claims true', () {
      expect(PushNotificationService.claimForDisplay(null), isTrue);
      expect(PushNotificationService.claimForDisplay(''), isTrue);
      expect(PushNotificationService.claimForDisplay(null), isTrue);
    });
  });
}
