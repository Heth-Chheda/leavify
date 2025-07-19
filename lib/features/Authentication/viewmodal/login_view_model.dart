import 'package:flutter/material.dart';
import 'package:leavify/app/routes.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginViewModel extends ChangeNotifier {
  final usernameController = TextEditingController(); // Single username field
  final passwordController = TextEditingController();

  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password are required')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Create login request with username (can be email or phone)
      final loginRequest = LoginRequest(username: username, password: password);

      final LoginResponseModel response = await _authenticationRepository.login(
        loginRequest,
      );

      // debugPrint("Login success: ${response.currentUser?.firstName}");

      // Save user to SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final jsonString = jsonEncode(response.toJson());
        prefs.setString('user_details', jsonString);
      });

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } catch (e) {
      debugPrint("Login error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
