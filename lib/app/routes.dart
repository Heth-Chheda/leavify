import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/view/login_view.dart';
import 'package:leavify/features/User/view/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/User/view/PendingRequests/pending_requests_screen.dart';
import 'package:leavify/features/User/view/landing_view.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String applyLeave = '/apply-leave';
  static const String profile = '/profile';
  static const String analytics = '/analytics';
  static const String pending = '/pending';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case home:
        return MaterialPageRoute(builder: (_) => const LandingView());

      case applyLeave:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Apply Leave'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            body: const ApplyLeaveScreen(),
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            body: const Placeholder(),
          ),
        );

      case analytics:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Analytics'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            body: const Placeholder(), // You'll need to create this
          ),
        );

      case pending:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Pending Requests'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            body: const PendingRequestsScreen(), // You'll need to create this
          ),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            body: const Placeholder(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No Route Defined'))),
        );
    }
  }
}
