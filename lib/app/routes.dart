import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/view/login_view.dart';
import 'package:leavify/features/User/view/landing_view.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case home:
        return MaterialPageRoute(builder: (_) => const LandingView());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No Route Defined'))),
        );
    }
  }
}
