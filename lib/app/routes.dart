import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/work_in_progress.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Authentication/view/login_view.dart';
import 'package:leavify/features/User/components/profile/leave_detail_screeen.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';
import 'package:leavify/features/User/view/ApplyLeave/apply_leave_screen.dart';
import 'package:leavify/features/User/view/landing_view.dart';
import 'package:leavify/features/User/view/manager/PendingRequests/pending_request.dart';
import 'package:leavify/features/User/view/profile/profile_screen.dart';
import 'package:leavify/services/force_update_checker.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String applyLeave = '/apply-leave';
  static const String profile = '/profile';
  static const String analytics = '/analytics';
  static const String pending = '/pending';
  static const String notifications = '/notifications';
  static const String leaveDetail = '/leave-detail';
  static const String announcements = '/announcements';
  static const String userSettings = '/settings';

  // Custom AppBar builder that adapts to theme
  static PreferredSizeWidget _buildThemedAppBar({
    required BuildContext context,
    required String title,
    bool showBackButton = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      centerTitle: true,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.chevron_left,
                size: 45,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case userSettings:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(context: context, title: 'Settings'),
            body: const Placeholder(),
          ),
        );
        break;

      case login:
        page = const LoginPage();
        break;

      case home:
        page = const LandingView();
        break;

      case applyLeave:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(context: context, title: 'Apply Leave'),
            body: const ApplyLeaveScreen(),
          ),
        );
        break;

      case profile:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(context: context, title: 'Profile'),
            body: const ProfileScreen(),
          ),
        );
        break;

      case leaveDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['leave'] is MyLeaves &&
            args['userId'] is String) {
          page = Builder(
            builder: (context) => Scaffold(
              appBar: _buildThemedAppBar(
                context: context,
                title: 'Leave Details',
              ),
              body: LeaveDetailScreen(
                leave: args['leave'] as MyLeaves,
                userId: args['userId'] as String,
              ),
            ),
          );
          break;
        }
        return _errorRoute('Invalid arguments for leave detail');

      case analytics:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(context: context, title: 'Analytics'),
            body: const WorkInProgressScreen(),
          ),
        );
        break;

      case pending:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(
              context: context,
              title: 'Pending Requests',
            ),
            body: const PendingLeavesScreen(),
            // body: const PendingRequestsScreen(),
          ),
        );
        break;

      case notifications:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(
              context: context,
              title: 'Notifications',
            ),
            body: const Placeholder(),
          ),
        );
        break;

      case announcements:
        page = Builder(
          builder: (context) => Scaffold(
            appBar: _buildThemedAppBar(
              context: context,
              title: 'Announcements',
            ),
            body: const Placeholder(),
          ),
        );
        break;

      default:
        return _errorRoute('No Route Defined');
    }

    // Wrap only the login page (initial route) with ForceUpdateWrapper
    if (settings.name == login) {
      page = ForceUpdateWrapper(child: page);
    }

    return MaterialPageRoute(builder: (_) => page);
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          appBar: _buildThemedAppBar(
            context: context,
            title: 'Error',
            showBackButton: true,
          ),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ]
                      : [
                          Colors.red.withOpacity(0.1),
                          Colors.red.withOpacity(0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkText.withOpacity(0.8)
                          : AppColors.lightText.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
