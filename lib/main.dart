import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:leavify/app/app.dart';
import 'package:leavify/core/config/app_environment.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:leavify/features/User/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';


void main() async {
  // MARK: REQUEST NOTIFICATION PERMISSIONS
  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  // MARK: INITIALIZE FCM
  Future<void> initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission on iOS
    await requestNotificationPermissions();

    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        // Wait a bit and try again, or handle accordingly
        await Future.delayed(Duration(seconds: 1));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
      debugPrint('APNS Token: $apnsToken');
    }

    // ✅ Now safe to get FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      AppStorage.saveString('USER_FCM_TOKEN', token);
      debugPrint('📲 FCM Token: $token');
    } else {
      debugPrint('❌ Failed to get FCM token');
      return;
    }

    // Listen to token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      AppStorage.saveString("USER_FCM_TOKEN", newToken);
      debugPrint('🔄 FCM Token Refreshed: $newToken');
    });
  }


  WidgetsFlutterBinding.ensureInitialized();
  await AppEnvironment.load();
  await AppStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeFCM();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => LeaveViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
