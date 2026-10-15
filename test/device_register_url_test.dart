import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/push_notification_service/device_register_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deregisterUrl encodes token for path segment', () {
    const token = 'abc:def/ghi';
    final url = DeviceRegisterPaths.deregisterUrl(
      ApiUrls.deviceDeregisterBase,
      token,
    );
    expect(url, startsWith(ApiUrls.deviceDeregisterBase));
    expect(url, contains(Uri.encodeComponent(token)));
    expect(url, isNot(contains('abc:def/ghi')));
  });

  test('deregisterUrl leaves typical FCM token unchanged when safe', () {
    const token = 'dGhpcy1pcy1hLWZha2UtZmNtLXRva2VuLWV4YW1wbGU';
    final url = DeviceRegisterPaths.deregisterUrl(
      ApiUrls.deviceDeregisterBase,
      token,
    );
    expect(url, '${ApiUrls.deviceDeregisterBase}$token');
  });
}
