// lib/routing/routers/leave_router.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leavify/app/router/route_names.dart';

// Screens
import 'package:leavify/features/User/view/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/User/components/profile/leave_detail_screeen.dart';
import 'package:leavify/features/User/view/manager/PendingRequests/pending_requests_screen.dart';
import 'package:leavify/features/User/components/manager/pending_request_detail_screen.dart';

// ViewModel
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';

/// Router dedicated to Leave flow.
/// Wraps the entire flow with a single LeaveViewModel instance.
class LeaveRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => LeaveViewModel(), // optional init
        child: _buildLeaveFlow(settings),
      ),
      settings: settings,
    );
  }

  /// Builds the actual screen for the leave flow
  static Widget _buildLeaveFlow(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.applyLeave:
        return const ApplyLeaveScreen();

      case RouteNames.leaveDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['leaveId'] is String &&
            args['userId'] is String) {
          return LeaveDetailScreen(
            leaveId: args['leaveId'] as String,
            userId: args['userId'] as String,
          );
        }
        return _invalidArgsRoute(
          settings,
          'Invalid arguments for Leave Detail',
        );

      case RouteNames.pendingRequests:
        return const PendingRequestsScreen();

      case RouteNames.pendingRequestDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['leaveId'] is String) {
          return PendingRequestDetailScreen(leaveId: args['leaveId'] as String);
        }
        return _invalidArgsRoute(
          settings,
          'Invalid arguments for Pending Request Detail',
        );
    }

    // Route not recognized in Leave flow
    return _invalidArgsRoute(settings, 'Unknown Leave Route');
  }

  static Widget _invalidArgsRoute(RouteSettings settings, String message) {
    return Scaffold(
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
