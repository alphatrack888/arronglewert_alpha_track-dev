import 'package:alpha_track/services/socket_service/socket_channel_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const userId = '507f1f77bcf86cd799439011';

  test('notification channel matches backend format', () {
    expect(
      SocketChannelNames.notificationChannel(userId),
      'notification::$userId',
    );
    expect(
      SocketChannelNames.notificationChannel(userId),
      isNot(contains('notification::::')),
    );
  });

  test('project channels match backend format', () {
    expect(SocketChannelNames.newProjectChannel(userId), 'newProject::$userId');
    expect(
      SocketChannelNames.removedProjectChannel(userId),
      'removedProject::$userId',
    );
  });

  test('empty user id still produces valid pattern for guards', () {
    expect(SocketChannelNames.notificationChannel(''), 'notification::');
  });
}
