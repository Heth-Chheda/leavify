import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leavify/app/app.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/config/app_environment.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Home/viewmodel/announcements_view_model.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:leavify/services/fcm_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

/// ⚠️ Development-only override for self-signed certificates.
/// Do NOT use this in production.
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          debugPrint('⚠️ Accepting self-signed certificate from $host:$port');
          return true;
        };
    return client;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app storage, environment, and Firebase
  await AppStorage.init();
  await AppEnvironment.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService.initialize();

  HttpOverrides.global = DevHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BaseViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AnnouncementViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
