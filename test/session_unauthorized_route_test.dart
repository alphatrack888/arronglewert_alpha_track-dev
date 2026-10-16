import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/services/auth/session_unauthorized.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routeForUnauthorized sends onboarded users to login', () {
    expect(
      routeForUnauthorized(onboardComplete: true),
      AppRoute.loginScreen,
    );
  });

  test('routeForUnauthorized sends new users to onboarding', () {
    expect(
      routeForUnauthorized(onboardComplete: false),
      AppRoute.onboardingScreen,
    );
  });
}
