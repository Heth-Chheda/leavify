import 'package:flutter/material.dart';
import 'package:leavify/base/base_repository.dart';
import 'package:leavify/core/utils/components/toast/app_toast.dart';

class BaseViewModel extends ChangeNotifier {
  // MARK: GLOBAL USER
  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _profileImage;
  String? _email;

  // MARK: GLOBAL GENERAL
  bool _isLoading = false;
  String? _errorMessage;

  // ------ Getters ------
  String? get userId => _userId;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get fullName => "${_firstName ?? ""} ${_lastName ?? ""}".trim();
  String? get profileImage => _profileImage;
  String? get email => _email;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ------- Setters -------
  void update({
    String? userId,
    String? firstName,
    String? lastName,
    String? profileImage,
    bool? isLoading,
    Object? errorMessage = const _Unset(),
  }) {
    if (userId != null) _userId = userId;
    if (firstName != null) _firstName = firstName;
    if (lastName != null) _lastName = lastName;
    if (profileImage != null) _profileImage = profileImage;
    if (isLoading != null) _isLoading = isLoading;
    if (errorMessage is! _Unset) _errorMessage = errorMessage as String?;

    notifyListeners();
  }

  // ------- Resetters -------
  void resetUser() {
    _userId = null;
    _firstName = null;
    _lastName = null;
    _profileImage = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void showSuccess(BuildContext context, String message) {
    AppToast.success(context, message);
  }

  void showError(BuildContext context, String message) {
    AppToast.error(context, message);
  }

  void showInfo(BuildContext context, String message) {
    AppToast.info(context, message);
  }

  String cleanErrorMessage(dynamic e) {
    if (e is ApiException) {
      if (e.message.contains("ClientException") ||
          e.message.contains("uri=") ||
          e.message.contains("Client is already closed")) {
        return "Network request failed. Please retry.";
      }
      return e.message;
    }
    // Fallback for non-ApiExceptions (crashes, parsing errors)
    return "Something went wrong";
  }
}

class _Unset {
  const _Unset();
}
