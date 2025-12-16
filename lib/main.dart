import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leavify/app/app.dart';
import 'package:leavify/core/config/app_environment.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/locator.dart';
import 'package:leavify/services/fcm_service.dart';

import 'firebase_options.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
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

  // Setup the ViewModel locator
  setupLocator();

  HttpOverrides.global = DevHttpOverrides();

  // The MultiProvider is no longer needed here as get_it handles the lifecycle.
  // We'll provide ViewModels at the route level in app_router.dart.
  runApp(const MyApp());
}
