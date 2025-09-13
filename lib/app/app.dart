import 'package:flutter/material.dart';
import 'package:leavify/app/router/app_navigator.dart';
import 'package:leavify/app/router/app_router.dart';
import 'package:leavify/app/splash_screen.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leavify',
      debugShowCheckedModeBanner: false,
      // initialRoute: Routes.login,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
      navigatorKey: AppNavigator
          .navigatorKey, // setting the key for the app is neccessary otherwise app navigator will not work.
      theme: AppTheme2.lightTheme,
      // themeMode: ThemeMode.system,
    );
  }
}
