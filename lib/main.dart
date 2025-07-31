import 'package:flutter/material.dart';
import 'package:leavify/app/app.dart';
import 'package:leavify/core/config/app_environment.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:leavify/features/User/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnvironment.load();
  await AppStorage.init();
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
