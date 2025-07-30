import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/view/login_view.dart';
import 'package:leavify/features/User/components/profile/leave_detail_screeen.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';
import 'package:leavify/features/User/view/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/User/view/PendingRequests/pending_requests_screen.dart';
import 'package:leavify/features/User/view/landing_view.dart';
import 'package:leavify/features/User/view/profile/profile_screen.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String applyLeave = '/apply-leave';
  static const String profile = '/profile';
  static const String analytics = '/analytics';
  static const String pending = '/pending';
  static const String notifications = '/notifications';
  static const String leaveDetail = '/leave-detail';

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
            body: const ProfileScreen(),
          ),
        );

      case leaveDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['leave'] is MyLeaves &&
            args['userId'] is String) {
          return MaterialPageRoute(
            builder: (_) => LeaveDetailScreen(
              leave: args['leave'] as MyLeaves,
              userId: args['userId'] as String,
            ),
          );
        }
        return _errorRoute('Invalid arguments for leave detail');

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
        return _errorRoute('No Route Defined');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
