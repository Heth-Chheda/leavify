import 'package:flutter/material.dart';
import 'package:leavify/app/app.dart';
import 'package:leavify/core/config/app_environment.dart';
import 'package:leavify/features/Authentication/viewmodal/login_view_model.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnvironment.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..initialize()),
      ],
      child: const MyApp(),
    ),
  );
}
