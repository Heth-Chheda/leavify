import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/work_in_progress.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:leavify/features/Profile/screens/profile_screen.dart';
import 'package:leavify/features/Leave/screen/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/Leave/components/manager/pending_request_detail_screen.dart';
import 'package:leavify/features/Leave/screen/manager/PendingRequests/pending_requests_screen.dart';
import 'package:leavify/features/Profile/components/leave_detail_screeen.dart';
import 'package:leavify/features/Home/screens/home_screen.dart';
import 'package:leavify/features/Authentication/view/login_view.dart';

// ViewModels
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';

import 'package:leavify/router/route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ----------------- AUTH ROUTES -----------------
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginPage(),
          ),
          settings: settings,
        );

      case RouteNames.analytics:
        return MaterialPageRoute(
          builder: (_) =>
              _withAppBar(const WorkInProgressScreen(), 'Dashboard'),
          settings: settings,
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // ----------------- LEAVE ROUTES -----------------
      case RouteNames.applyLeave:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => LeaveViewModel()),
            ],
            child: _withAppBar(const ApplyLeaveScreen(), 'Apply leave'),
          ),
          settings: settings,
        );

      case RouteNames.pendingRequests:
        return MaterialPageRoute(
          builder: (_) =>
              _withAppBar(const PendingRequestsScreen(), 'Pending Requests'),
          settings: settings,
        );

      case RouteNames.pendingRequestDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['leaveId'] is String) {
          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => LeaveViewModel(),
              child: _withAppBar(
                PendingRequestDetailScreen(
                  leaveId: args['leaveId'] as String,
                  user: args['user'] as GetAllResponse?,
                ),
                'Leave Request Details',
              ),
            ),
            settings: settings,
          );
        }
        return _invalidArgsRoute(
          settings,
          "Invalid arguments for Pending Request Detail",
        );

      case RouteNames.leaveDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['leaveId'] is String &&
            args['userId'] is String) {
          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => LeaveViewModel(),
              child: _withAppBar(
                LeaveDetailScreen(
                  key: leaveDetailKey,
                  leaveId: args['leaveId'] as String,
                  userId: args['userId'] as String,
                ),
                'Leave Details',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      final state = leaveDetailKey.currentState;
                      state?.toggleEditModel();
                    },
                  ),
                ],
              ),
            ),
            settings: settings,
          );
        }
        return _invalidArgsRoute(
          settings,
          "Invalid arguments for Leave Detail",
        );

      // ----------------- PROFILE ROUTE -----------------
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => _withAppBar(const ProfileScreen(), 'Profile'),
          settings: settings,
        );

      // ----------------- FALLBACK -----------------
      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _invalidArgsRoute(
    RouteSettings settings,
    String message,
  ) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            '❌ $message\nRoute: ${settings.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
      settings: settings,
    );
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

  static Widget _withAppBar(
    Widget child,
    String title, {
    List<Widget>? actions,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, textAlign: TextAlign.center),
        centerTitle: true,
        leading: const BackButton(),
        // Only add actions if provided
        actions: actions != null ? actions : null,
      ),
      body: child,
    );
  }
}
