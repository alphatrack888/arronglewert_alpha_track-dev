// ignore: file_names
import 'package:alpha_track/core/app_route/app_route.dart';
import 'package:alpha_track/screens/error_screen/erro_screen.dart';
import 'package:alpha_track/services/connectivity_services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetCheckMiddleWare extends GetMiddleware {
  final ConnectivityService connectivityService =
      Get.find<ConnectivityService>();

  @override
  RouteSettings? redirect(String? route) {
    if (connectivityService.connectionStatus.contains(
      ConnectivityResult.none,
    )) {
      // Store the current route for navigation back when internet is restored
      connectivityService.setPreviousRoute(route ?? AppRoute.splashScreen);
      return RouteSettings(
        name: AppRoute.errorScreen,
        arguments: {'previousRoute': route},
      );
    }
    return super.redirect(route);
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (connectivityService.connectionStatus.contains(
      ConnectivityResult.none,
    )) {
      // Store the current route for navigation back when internet is restored
      connectivityService.setPreviousRoute(page?.name ?? AppRoute.splashScreen);
      return GetPage(
        name: AppRoute.errorScreen,
        page: () => const ErrorScreen(),
        arguments: {'previousRoute': page?.name},
      );
    }
    return super.onPageCalled(page);
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    if (connectivityService.connectionStatus.contains(
      ConnectivityResult.none,
    )) {
      return () => const ErrorScreen();
    }
    return super.onPageBuildStart(page);
  }
}
