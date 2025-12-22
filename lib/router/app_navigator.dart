import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Push a new route on top of stack
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    final navigator = navigatorKey.currentState;
    assert(navigator != null, 'NavigatorState is not ready');

    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  /// Replace entire stack with new root view
  static Future<dynamic>? setRootView(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current screen
  static void goBack<T extends Object?>([T? result]) {
    return navigatorKey.currentState?.pop(result);
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }
}
