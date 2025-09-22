// lib/routing/routers/leave_router.dart

import 'package:flutter/material.dart';
import 'package:leavify/features/Profile/screens/profile_screen.dart';
import 'package:leavify/features/Profile/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:leavify/router/route_names.dart';

// Screens
import 'package:leavify/features/Leave/screen/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/Profile/components/leave_detail_screeen.dart';
import 'package:leavify/features/Leave/screen/manager/PendingRequests/pending_requests_screen.dart';
import 'package:leavify/features/Leave/components/manager/pending_request_detail_screen.dart';

// ViewModel
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';

/// Router dedicated to Leave flow.
/// Wraps the entire flow with a single LeaveViewModel instance.
class LeaveRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Widget? screen = _buildLeaveFlow(settings);
    if (screen == null) return null;
    return MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LeaveViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ],
        child: screen,
      ),
      settings: settings,
    );
  }

  /// Builds the actual screen for the leave flow
  static Widget? _buildLeaveFlow(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.applyLeave:
        return _withAppBar(const ApplyLeaveScreen(), "Apply Leave");

      case RouteNames.profile:
        return _withAppBar(const ProfileScreen(), 'My Profile');

      case RouteNames.leaveDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['leaveId'] is String &&
            args['userId'] is String) {
          return _withAppBar(
            LeaveDetailScreen(
              leaveId: args['leaveId'] as String,
              userId: args['userId'] as String,
            ),
            "Leave Detail",
          );
        }
        return _invalidArgsRoute(
          settings,
          "Invalid arguments for Leave Detail",
        );

      case RouteNames.pendingRequests:
        return _withAppBar(const PendingRequestsScreen(), "Pending Requests");

      case RouteNames.pendingRequestDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['leaveId'] is String) {
          return _withAppBar(
            PendingRequestDetailScreen(leaveId: args['leaveId'] as String),
            "Request Detail",
          );
        }
        return _invalidArgsRoute(
          settings,
          "Invalid arguments for Pending Request Detail",
        );

      default:
        return null;
    }
  }

  /// Wraps a screen with a Scaffold and AppBar
  static Widget _withAppBar(Widget child, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, textAlign: TextAlign.center),
        centerTitle: true,
        leading: const BackButton(), // back arrow on the left
      ),
      body: child,
    );
  }

  static Widget _invalidArgsRoute(RouteSettings settings, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Error"),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: Center(
        child: Text(
          '❌ $message\nRoute: ${settings.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }
}
