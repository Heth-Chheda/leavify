import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screen and ViewModel
import 'package:leavify/features/Authentication/view/login_view.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';

// Core
import 'package:leavify/locator.dart';
import 'package:leavify/router/route_names.dart';

class AuthenticationRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: locator<LoginViewModel>(),
            child: const LoginPage(),
          ),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
