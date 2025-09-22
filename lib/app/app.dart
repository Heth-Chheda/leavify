import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/app_router.dart';
import 'package:leavify/app/splash_screen.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leavify',
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          // Initialize toast overlay here — after MaterialApp and Overlay exist
          WidgetsBinding.instance.addPostFrameCallback((_) {
            InteractiveToast.initializeOverlayState(Overlay.of(context));
          });

          return const SplashScreen();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
      navigatorKey: AppNavigator.navigatorKey,
      theme: AppTheme2.lightTheme,
    );
  }
}
