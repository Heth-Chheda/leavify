import 'package:flutter/material.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';

class LoginViewModel extends BaseViewModel {
  final usernameController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');

  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  Future<void> login(BuildContext context) async {
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    // Validation of email.
    // final usernameValidation = ValidationUtils.validateUsernameAsEmailOrPhone(
    //   username,
    // );
    // if (usernameValidation != null) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(usernameValidation)));
    //   return;
    // }

    // Validation of password.
    // final passwordValidation = ValidationUtils.validatePassword(password);
    // if (passwordValidation != null) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(passwordValidation)));
    //   return;
    // }

    update(isLoading: true);
    notifyListeners();

    final fcmToken = await AppStorage.getString('USER_FCM_TOKEN');
    if (!context.mounted) return;
    try {
      // Create login request with username (can be email or phone)
      // keeping it email for now later can be changed to dynamic according to the requirement
      if (fcmToken == null || fcmToken.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('FCM token is not available')));
        return;
      }

      final loginRequest = LoginRequest(
        username: username,
        password: password,
        loginType: 'EMAIL',
        fcmToken: fcmToken,
      );
      // logins only
      await _authenticationRepository.login(loginRequest);
      if (!context.mounted) return;
      AppNavigator.setRootView(RouteNames.home);
      showSuccess(context, "Login successful");
    } catch (e) {
      debugPrint("Login error: $e");
      showError(context, 'Login error: $e');
    } finally {
      update(isLoading: false);
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
