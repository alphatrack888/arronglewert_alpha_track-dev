import 'package:alpha_track/utils/notification_routing/notification_routing.dart';

/// Holds a tapped notification until authenticated navigation is ready.
class PendingNotificationRoute {
  NotificationDestination? _destination;
  bool _ready = false;

  void enqueue(NotificationDestination destination) => _destination = destination;

  void markReady() => _ready = true;

  NotificationDestination? take() {
    if (!_ready) return null;
    final destination = _destination;
    _destination = null;
    return destination;
  }

  void reset() {
    _ready = false;
    _destination = null;
  }
}
