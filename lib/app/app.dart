import 'package:flutter/material.dart';
import 'package:leavify/app/routes.dart';
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
      onGenerateRoute: Routes.generateRoute,
      theme: AppTheme2.lightTheme,
      // themeMode: ThemeMode.system,
    );
  }
}
