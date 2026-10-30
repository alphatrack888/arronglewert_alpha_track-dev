import 'package:alpha_track/services/push_notification_service/notification_hygiene.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a granted phone hides the status line', () {
    final prompt = osNotificationPrompt(
      allowed: true,
      permanentlyDenied: false,
    );
    expect(prompt.showStatus, isFalse);
  });

  test('a soft denial asks once and a permanent denial opens settings', () {
    final soft = osNotificationPrompt(
      allowed: false,
      permanentlyDenied: false,
    );
    expect(soft.showStatus, isTrue);
    expect(soft.action, OsNotificationAction.allow);

    final permanent = osNotificationPrompt(
      allowed: false,
      permanentlyDenied: true,
    );
    expect(permanent.showStatus, isTrue);
    expect(permanent.action, OsNotificationAction.openSettings);
  });

  test('delete outcomes keep the token only when the server did not answer', () {
    expect(
      pendingDeleteDecision(
        statusCode: 200,
        savedUserId: 'user-a',
        currentUserId: 'user-a',
      ),
      PendingDeleteDecision.deleted,
    );
    expect(
      pendingDeleteDecision(
        statusCode: 404,
        savedUserId: 'user-a',
        currentUserId: 'user-a',
      ),
      PendingDeleteDecision.alreadyGone,
    );
    expect(
      pendingDeleteDecision(
        statusCode: 404,
        savedUserId: 'user-a',
        currentUserId: 'user-b',
      ),
      PendingDeleteDecision.notAllowed,
    );
    expect(
      pendingDeleteDecision(
        statusCode: null,
        savedUserId: 'user-a',
        currentUserId: 'user-a',
      ),
      PendingDeleteDecision.keep,
    );
    expect(
      pendingDeleteDecision(
        statusCode: 500,
        savedUserId: 'user-a',
        currentUserId: 'user-a',
      ),
      PendingDeleteDecision.keep,
    );

    expect(pendingDeleteClears(PendingDeleteDecision.deleted), isTrue);
    expect(pendingDeleteClears(PendingDeleteDecision.alreadyGone), isTrue);
    expect(pendingDeleteClears(PendingDeleteDecision.notAllowed), isTrue);
    expect(pendingDeleteClears(PendingDeleteDecision.keep), isFalse);
  });
}
