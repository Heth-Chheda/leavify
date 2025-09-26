import 'package:flutter/material.dart';
import 'package:leavify/features/Profile/screens/profile_screen.dart';
import 'package:leavify/features/Profile/viewmodel/profile_view_model.dart';
import 'package:leavify/router/routes/leave_router.dart';
import 'package:provider/provider.dart';
import 'package:leavify/router/route_names.dart';

class ProfileRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Widget? screen = _buildProfileRoute(settings);
    if (screen == null) return null;

    return MaterialPageRoute(
      builder: (context) => MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ProfileViewModel())],
        child: Builder(
          builder: (context) {
            return screen;
          },
        ),
      ),
      settings: settings,
    );
  }

  static Widget? _buildProfileRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.profile:
        return LeaveRouter.withAppBar(const ProfileScreen(), 'My Profile');

      default:
        return null;
    }
  }
}
