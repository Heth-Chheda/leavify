// lib/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:leavify/router/routes/authenticaion_router.dart';
import 'package:leavify/router/routes/leave_router.dart';
import 'package:leavify/router/routes/profile_router.dart';

// Import flow routers

/// AppRouter delegates routing to each flow router.
/// Each flow router returns a Route if it can handle it,
/// otherwise returns null so the next router can try.
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 1️⃣ Try Authentication flow
    final authRoute = AuthenticationRouter.onGenerateRoute(settings);
    if (authRoute != null) return authRoute;

    // 2️⃣ Try Leave flow
    final leaveRoute = LeaveRouter.onGenerateRoute(settings);
    if (leaveRoute != null) return leaveRoute;

    // 3️⃣ Try Profile flow
    final profileRoute = ProfileRouter.onGenerateRoute(settings);
    if (profileRoute != null) return profileRoute;

    // 4️⃣ Fallback: unknown route
    return _errorRoute(settings.name);
  }

  static MaterialPageRoute _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Route Not Found')),
        body: Center(
          child: Text(
            '❌ Route not found: $routeName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
