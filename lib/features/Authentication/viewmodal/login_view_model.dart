import 'package:flutter/material.dart';
import 'package:leavify/core/utils/validation_utils.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';

class LoginViewModel extends ChangeNotifier {
  final usernameController = TextEditingController(
    text: 'Neel.chheda@ritetechnologies.co.in',
  );
  final passwordController = TextEditingController(text: '1234');

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
    // final passwordValidation = ValidationUtils.validatePassword(password);
    // if (passwordValidation != null) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(passwordValidation)));
    //   return;
    // }

    isLoading = true;
    notifyListeners();

    try {
      // Create login request with username (can be email or phone)
      // keeping it email for now later can be changed to dynamic according to the requirement
      final loginRequest = LoginRequest(
        username: username,
        password: password,
        loginType: 'EMAIL',
        fcmToken:
            '', // also get the fcm token on generation. For temp keeping it anything
      );

      // logins only
      await _authenticationRepository.login(loginRequest);

      if (!context.mounted) return;

      Navigator.pushNamed(context, '/home');
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
