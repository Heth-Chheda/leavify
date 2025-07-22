import 'package:flutter/material.dart';
import 'package:leavify/app/routes.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/validation_utils.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';

class LoginViewModel extends ChangeNotifier {
  final usernameController = TextEditingController(); // Single username field
  final passwordController = TextEditingController();

  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    // Validation of email.
    final usernameValidation = ValidationUtils.validateUsernameAsEmailOrPhone(
      username,
    );
    if (usernameValidation != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(usernameValidation)));
      return;
    }

    // Validation of password.
    final passwordValidation = ValidationUtils.validatePassword(password);
    if (passwordValidation != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(passwordValidation)));
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

      // Save user to SharedPreferences
      AppStorage.saveObject("user_details", response.toJson());

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
