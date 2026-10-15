/// URL helpers for device token register/deregister (unit-tested in P5).
class DeviceRegisterPaths {
  DeviceRegisterPaths._();

  /// Backend: `DELETE /devices/:token` — encode token for use as a single path segment.
  static String deregisterUrl(String deviceDeregisterBase, String token) {
    final encoded = Uri.encodeComponent(token);
    return '$deviceDeregisterBase$encoded';
  }
}
