import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:leavify/base/base_repository.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/app_router.dart';
import 'package:leavify/app/splash_screen.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/router/route_names.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Schedule toast initialization AFTER the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = AppNavigator.navigatorKey.currentState?.overlay;
      if (overlay != null) {
        InteractiveToast.initializeOverlayState(overlay);
      } else {
        debugPrint('⚠️ Overlay not ready yet. Will retry on next frame.');
      }
    });

    BaseRepository.onSessionExpired = (msg) {
      final context = AppNavigator.navigatorKey.currentContext!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: ConfirmationDialog(
            title: "Session Expired",
            body: msg,
            illustrationAsset: "lib/assets/session_expired.png",
            illustrationHeight: 150,
            confirmButtonText: "OK",
            onConfirm: () {
              Navigator.of(context).pop();
              _performLogout();
              AppNavigator.setRootView(RouteNames.login);
            },
          ),
        ),
      );
    };
  }

  void _performLogout() {
    unawaited(AppStorage.clearAllExcept("USER_FCM_TOKEN"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leavify',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      theme: AppTheme2.lightTheme,
      // Lock system font scaling globally
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
