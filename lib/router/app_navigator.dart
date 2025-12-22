import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void _dismissKeyboard() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      FocusScope.of(context).unfocus();
    }
  }

  /// Push a new route on top of stack
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    _dismissKeyboard();
    final navigator = navigatorKey.currentState;
    assert(navigator != null, 'NavigatorState is not ready');

    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  /// Replace entire stack with new root view
  static Future<dynamic>? setRootView(String routeName, {Object? arguments}) {
    _dismissKeyboard();
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current screen
  static void goBack<T extends Object?>([T? result]) {
    _dismissKeyboard();
    return navigatorKey.currentState?.pop(result);
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    _dismissKeyboard();
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }
}
