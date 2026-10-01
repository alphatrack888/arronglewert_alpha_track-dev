/// Holds a tapped notification until authenticated navigation is ready.
class PendingNotificationRoute {
  String? _route;
  bool _ready = false;

  void enqueue(String route) => _route = route;
  void markReady() => _ready = true;

  String? take() {
    if (!_ready) return null;
    final route = _route;
    _route = null;
    return route;
  }

  void reset() {
    _ready = false;
    _route = null;
  }
}
