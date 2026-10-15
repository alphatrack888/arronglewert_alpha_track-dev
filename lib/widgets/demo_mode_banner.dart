import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:flutter/material.dart';

/// Wraps the app when [kDemoMode] is true so reviewers know data is fake.
Widget wrapWithDemoModeBanner(Widget? child) {
  if (child == null) return const SizedBox.shrink();
  if (!kDemoMode) return child;
  return Banner(
    message: 'DEMO',
    location: BannerLocation.topEnd,
    color: Colors.deepOrange,
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: 0.5,
    ),
    child: child,
  );
}
