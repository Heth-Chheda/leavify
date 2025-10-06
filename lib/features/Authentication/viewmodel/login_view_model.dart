import 'package:flutter/material.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
// import 'package:leavify/dummydata/login/dummy_login_response.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

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
      // showInfo(context, '$loginRequest');
      // logins only
      final result = await _authenticationRepository.login(loginRequest);
      // final result = dummyLoginData;

      if (result.success) {
        // Initialize home viewModel and then navigate to home screen.
        // this is important to load because home screen is dependent on this data.
        final homeViewModel = context.read<HomeViewModel>();
        await homeViewModel.initialize();
        await AppStorage.saveBoolean('USER_IS_ALREADY_LOGGED_IN', true);

        // await Future.delayed(const Duration(milliseconds: 500));
        if (!context.mounted) return;
        AppNavigator.setRootView(RouteNames.home);
        showSuccess(context, "Login successful");
      } else {
        showError(context, 'Please try again later.');
      }
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
