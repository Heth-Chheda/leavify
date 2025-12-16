import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/work_in_progress.dart';
import 'package:leavify/features/Home/screens/home_screen.dart';
// ViewModels
import 'package:leavify/features/Home/viewmodel/announcements_view_model.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Profile/screens/other_user_profile_screen.dart';
// Screens
import 'package:leavify/features/Profile/screens/profile_screen.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:leavify/locator.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/authentication_router.dart';
import 'package:leavify/router/leave_router.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Attempt to generate route from AuthenticationRouter
    final authRoute = AuthenticationRouter.generateRoute(settings);
    if (authRoute != null) {
      return authRoute;
    }

    // Attempt to generate route from LeaveRouter
    final leaveRoute = LeaveRouter.generateRoute(settings);
    if (leaveRoute != null) {
      return leaveRoute;
    }

    // Handle remaining routes
    switch (settings.name) {
      case RouteNames.analytics:
        return MaterialPageRoute(
          builder: (_) =>
              _withAppBar(const WorkInProgressScreen(), 'Dashboard'),
          settings: settings,
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: locator<HomeViewModel>()),
              ChangeNotifierProvider.value(
                value: locator<AnnouncementViewModel>(),
              ),
            ],
            child: const HomeScreen(),
          ),
          settings: settings,
        );

      // ----------------- PROFILE ROUTE -----------------
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: locator<ProfileViewModel>()),
              ChangeNotifierProvider.value(value: locator<HomeViewModel>()),
            ],
            child: _withAppBar(const ProfileScreen(), 'Profile'),
          ),
          settings: settings,
        );

      case RouteNames.otherUserProfile:
        // Extract the userId passed as argument
        final userId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              // Inject the same ViewModels so the screen can fetch data
              ChangeNotifierProvider.value(value: locator<HomeViewModel>()),
              ChangeNotifierProvider.value(value: locator<ProfileViewModel>()),
            ],
            // We use the screen directly because it has its own Scaffold & AppBar
            child: OtherUserProfileScreen(userId: userId),
          ),
          settings: settings,
        );

      // ----------------- FALLBACK -----------------
      default:
        return _errorRoute(settings.name);
    }
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
    String? title, {
    List<Widget>? actions,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "", textAlign: TextAlign.center),
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
        // Only add actions if provided
        actions: actions != null ? actions : null,
      ),
      body: child,
    );
  }
}
