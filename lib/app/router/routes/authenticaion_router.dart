// lib/routing/routers/authentication_router.dart

import 'package:flutter/material.dart';
import 'package:leavify/features/User/view/home_screen.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:leavify/app/router/route_names.dart';

// Screens
import 'package:leavify/features/Authentication/view/login_view.dart';
// import 'package:leavify/features/Authentication/view/register_view.dart';
// import 'package:leavify/features/Authentication/view/forgot_password_view.dart';

// ViewModel
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';

/// Router dedicated to Authentication flow.
/// Wraps the entire flow with a single LoginViewModel instance.
class AuthenticationRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
        ],
        child: _buildAuthFlow(settings),
      ),
      settings: settings,
    );
  }

  /// Builds the actual screen for the route
  static Widget _buildAuthFlow(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return const LoginPage();

      case RouteNames.home:
        return const HomeScreen();

      // Example placeholders for future screens
      // case RouteNames.register:
      //   return const RegisterScreen();
      //
      // case RouteNames.forgotPassword:
      //   return const ForgotPasswordScreen();
    }

    // Fallback for unknown auth routes
    return Scaffold(
      body: Center(
        child: Text(
          '❌ Unknown Authentication Route: ${settings.name}',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
