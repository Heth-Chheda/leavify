import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumberController = TextEditingController();

  bool isLoading = false;

  Future<void> loginWithEmail(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // TODO: Call your API client here
      await Future.delayed(const Duration(seconds: 2)); // simulate request
      debugPrint("Logged in with $email : $password");

      // Navigate to dashboard or home
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

  Future<void> loginWithPhone(BuildContext context) async {
    final password = passwordController.text;
    final phoneNumber = phoneNumberController.text;

    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // TODO: Call your API client here
      await Future.delayed(const Duration(seconds: 2)); // simulate request
      debugPrint("Logged in with $phoneNumber : $password");

      // Navigate to dashboard or home
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
    super.dispose();
  }
}
