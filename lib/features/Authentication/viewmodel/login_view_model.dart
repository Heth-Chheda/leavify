import 'package:flutter/material.dart';
import 'package:leavify/base/base_repository.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Authentication/domain/request/login_request.dart';
import 'package:leavify/locator.dart';
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

    update(isLoading: true);
    notifyListeners();

    final fcmToken = await AppStorage.getString('USER_FCM_TOKEN');
    if (!context.mounted) return;

    try {
      if (fcmToken == null || fcmToken.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FCM token is not available')),
        );
        return;
      }

      final loginRequest = LoginRequest(
        username: username,
        password: password,
        loginType: 'EMAIL',
        fcmToken: fcmToken,
      );

      final result = await _authenticationRepository.login(loginRequest);

      if (result.success) {
        // Access HomeViewModel directly from the locator
        final homeViewModel = locator<HomeViewModel>();
        await homeViewModel.initialize();
        await AppStorage.saveBoolean('USER_IS_ALREADY_LOGGED_IN', true);

        if (!context.mounted) return;
        AppNavigator.setRootView(RouteNames.home);
        showSuccess(context, "Login successful");
      } else {
        if (!context.mounted) return;
        showError(context, 'Please try again later.');
      }
    } catch (e) {
      debugPrint("Login error: $e");
      if (!context.mounted) return;

      // UPDATED: Use the clean error message helper
      showError(context, cleanErrorMessage(e));

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