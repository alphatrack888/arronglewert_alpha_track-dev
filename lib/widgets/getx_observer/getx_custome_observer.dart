import 'package:flutter/material.dart';

class NavigationObserver extends NavigatorObserver {
  final List<String> routeStack = <String>[];

  // ANSI Color codes for colorful output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _bold = '\x1B[1m';

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = route.settings.name ?? 'Unknown';
    routeStack.add(routeName);
    _printColored(
      '🚀 PUSH',
      '$_green$_bold${routeName.replaceAll('/', '')}$_reset',
      'Stack: ${routeStack.length}',
      'Full: $_cyan${routeStack.join(' → ')}$_reset',
    );
    // _logControllersForRoute(routeName);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final routeName = route.settings.name ?? 'Unknown';
    routeStack.remove(routeName);
    _printColored(
      '⬅️  POP',
      '$_yellow$_bold${routeName.replaceAll('/', '')}$_reset',
      'Stack: ${routeStack.length}',
      'Remaining: $_cyan${routeStack.join(' → ')}$_reset',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      final newName = newRoute.settings.name ?? 'Unknown';
      final oldName = oldRoute?.settings.name ?? 'Unknown';
      routeStack.remove(oldName);
      routeStack.add(newName);
      _printColored(
        '🔄 REPLACE',
        '$_magenta$oldName$_reset → $_green$_bold$newName$_reset',
        'Stack: ${routeStack.length}',
        'Full: $_cyan${routeStack.join(' → ')}$_reset',
      );
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = route.settings.name ?? 'Unknown';
    routeStack.remove(routeName);
    _printColored(
      '🗑️  REMOVE',
      '$_red$_bold$routeName$_reset',
      'Stack: ${routeStack.length}',
      'Remaining: $_cyan${routeStack.join(' → ')}$_reset',
    );
  }

  void _printColored(
    String action,
    String routeInfo,
    String stackInfo,
    String fullStack,
  ) {
    print('$_bold[$action]$_reset $routeInfo | $stackInfo | $fullStack');
  }

  // void _logControllersForRoute(String routeName) {
  //   final allControllers =  G.controllers;
  //   print('$_blue${'='*60}$_reset');
  //   print('$_bold$_cyan📱 CONTROLLERS for $routeName$_reset');
  //   print('$_blue${'='*60}$_reset');

  //   if (allControllers.isEmpty) {
  //     print('  $_dim😴 No active controllers$_reset');
  //     return;
  //   }

  //   for (final controller in allControllers) {
  //     final tags = controller.tags;
  //     final isPermanent = controller.permanent;
  //     final statusColor = isPermanent ? _green : _yellow;
  //     print('  ${_magenta}•${_reset} '
  //         '${_bold}${controller.runtimeType}$_reset '
  //         '$_dim(tags: ${tags?.join(', ') ?? 'none'})$_reset '
  //         '$statusColor${isPermanent ? '🔒 PERMANENT' : '⏳ TEMPORARY'}$_reset');
  //   }
  //   print('$_blue${'='*60}$_reset\n');
  // }
}
