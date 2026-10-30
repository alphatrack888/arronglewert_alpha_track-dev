import 'package:alpha_track/services/push_notification_service/foreground_alert.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payload includes routing fields and omits an absent kind', () {
    final withKind = foregroundNotificationPayload(
      title: 'Leave update',
      body: 'Your request was approved',
      notificationId: 'abc123',
      category: 'leave',
      kind: 'leaveRequestStatusChanged',
    );
    expect(withKind, {
      'title': 'Leave update',
      'body': 'Your request was approved',
      'notificationId': 'abc123',
      'category': 'leave',
      'kind': 'leaveRequestStatusChanged',
    });

    final withoutKind = foregroundNotificationPayload(
      title: 'Leave update',
      body: 'Your request was approved',
      notificationId: 'abc123',
      category: 'leave',
    );
    expect(withoutKind.containsKey('kind'), isFalse);
    expect(withoutKind['category'], 'leave');
  });

  test('a background lifecycle does not claim and does not build a post', () {
    for (final state in [
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.detached,
    ]) {
      final plan = SocketBannerPlan.decide(
        lifecycle: state,
        title: 'Clock-out',
        body: 'You are still clocked in',
        notificationId: 'session-1',
        category: 'attendance',
        kind: 'forgotClockOut',
      );
      expect(plan.claim, isFalse, reason: state.name);
      expect(plan.payload, isNull, reason: state.name);
    }
  });

  test('a foreground lifecycle claims and builds the post', () {
    final plan = SocketBannerPlan.decide(
      lifecycle: AppLifecycleState.resumed,
      title: 'Clock-out',
      body: 'You are still clocked in',
      notificationId: 'session-1',
      category: 'attendance',
    );
    expect(plan.claim, isTrue);
    expect(plan.payload?['notificationId'], 'session-1');
    expect(plan.payload?['category'], 'attendance');
    expect(plan.payload?.containsKey('kind'), isFalse);
  });
}
