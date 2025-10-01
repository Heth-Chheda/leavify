import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leavify/app/app.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/config/app_environment.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:leavify/services/fcm_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  await AppEnvironment.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BaseViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
