/// Backend Socket.IO event names (see time-tracker notificationHelper / project.service).
class SocketChannelNames {
  SocketChannelNames._();

  static String notificationChannel(String userId) => 'notification::$userId';

  static String newProjectChannel(String userId) => 'newProject::$userId';

  static String removedProjectChannel(String userId) => 'removedProject::$userId';
}
