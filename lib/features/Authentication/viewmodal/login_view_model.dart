import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';

enum LoginType { email, phone }

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  bool isLoading = false;

  Future<void> login(BuildContext context, LoginType loginType) async {
    final password = passwordController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNumberController.text.trim();

    if (password.isEmpty ||
        (loginType == LoginType.email && email.isEmpty) ||
        (loginType == LoginType.phone && phone.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credentials are required')));
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Create login request based on type
      final loginRequest = loginType == LoginType.email
          ? LoginRequest(email: email, password: password)
          : LoginRequest(phoneNumber: phone, password: password);

      final LoginResponseModel response = await _authenticationRepository.login(
        loginRequest,
      );

      debugPrint("Login success: ${response.currentUser?.firstName}");

      // TODO: Save token & user to SharedPreferences

      // TODO: Navigate based on user role or screen
      // Navigator.pushReplacementNamed(context, Routes.home);
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
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}
