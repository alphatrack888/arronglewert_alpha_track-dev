import 'package:flutter/material.dart';

class AppSize {
  AppSize._();

  static Size? _size;

  /// Screen size cached from MediaQuery at app start (splash/error screens).
  static set size(Size value) => _size = value;

  /// Reads the cached size, or falls back to the real platform window if it
  /// hasn't been set yet — e.g. a deep-link / web reload landing straight on a
  /// screen that skips splash. Previously `late`, which threw
  /// LateInitializationError (blank screen) on that path.
  static Size get size {
    final cached = _size;
    if (cached != null) return cached;
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view != null) {
      return view.physicalSize / view.devicePixelRatio;
    }
    return const Size(_xdWidth, _xdHeight);
  }

  static const double _xdHeight = 882;
  static const double _xdWidth = 375;

  static double height({required num value}) {
    double percentage = (value / _xdHeight * 100).roundToDouble() / 100;
    return size.height * percentage;
  }

  static double width({required num value}) {
    double percentage = (value / _xdWidth * 100).roundToDouble() / 100;
    return size.width * percentage;
  }
}

class ResponsiveUtils {
  ResponsiveUtils._();

  static double screenHeight = 0;
  static double screenWidth = 0;

  static void initialize(BuildContext context) {
    screenHeight = MediaQuery.sizeOf(context).height;
    screenWidth = MediaQuery.sizeOf(context).width;
  }

  // Function to calculate responsive height
  static double height(double height) {
    return screenHeight / (screenHeight / height);
  }

  // Function to calculate responsive width
  static double width(double width) {
    return screenWidth / (screenWidth / width);
  }
}
