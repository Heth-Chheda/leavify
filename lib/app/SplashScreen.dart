import 'package:flutter/material.dart';
import 'package:leavify/app/routes.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AppStorage.getBoolean('USER_IS_ALREADY_LOGGED_IN');
    if (isLoggedIn == true) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash/loading indicator
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
