import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:leavify/features/Leave/screen/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/Leave/components/manager/pending_request_detail_screen.dart';
import 'package:leavify/features/Leave/screen/manager/PendingRequests/pending_requests_screen.dart';
import 'package:leavify/features/Profile/components/leave_detail_screeen.dart';

// ViewModel
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';

// Core
import 'package:leavify/locator.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';

class LeaveRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.applyLeave:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: locator<LeaveViewModel>()),
              ChangeNotifierProvider.value(value: locator<HomeViewModel>()),
            ],
            child: _withAppBar(const ApplyLeaveScreen(), 'Apply leave'),
          ),
          settings: settings,
        );

      case RouteNames.pendingRequests:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: locator<LeaveViewModel>()),
              ChangeNotifierProvider.value(value: locator<HomeViewModel>()),
            ],
            child: _withAppBar(
              const PendingRequestsScreen(),
              "Pending Requests",
            ),
          ),
          settings: settings,
        );

      case RouteNames.pendingRequestDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['leaveId'] is String) {
          return MaterialPageRoute(
            builder: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: locator<LeaveViewModel>()),
                ChangeNotifierProvider.value(value: locator<HomeViewModel>()),
              ],
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
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: locator<LeaveViewModel>()),
                ChangeNotifierProvider.value(
                    value: locator<ProfileViewModel>()),
              ],
              child: Consumer<ProfileViewModel>(
                builder: (context, viewModel, _) {
                  return _withAppBar(
                    LeaveDetailScreen(
                      leaveId: args['leaveId'] as String,
                      userId: args['userId'] as String,
                    ),
                    'Leave Details',
                    actions: [
                      IconButton(
                        icon: Icon(
                          viewModel.isEditMode ? Icons.close : Icons.edit,
                        ),
                        onPressed: () => viewModel.toggleEditMode(),
                      ),
                    ],
                  );
                },
              ),
            ),
            settings: settings,
          );
        }
        return _invalidArgsRoute(
          settings,
          "Invalid arguments for Leave Detail",
        );

      default:
        return null;
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

  static Widget _withAppBar(Widget child, String title, {List<Widget>? actions}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, textAlign: TextAlign.center),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            final canPop =
                AppNavigator.navigatorKey.currentState?.canPop() ?? false;

            if (canPop) {
              AppNavigator.goBack();
            } else {
              AppNavigator.setRootView(RouteNames.home);
            }
          },
        ),
        actions: actions != null ? actions : null,
      ),
      body: child,
    );
  }
}
