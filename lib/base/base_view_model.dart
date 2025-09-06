import 'package:flutter/material.dart';

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
    String? errorMessage,
  }) {
    if (userId != null) _userId = userId;
    if (firstName != null) _firstName = firstName;
    if (lastName != null) _lastName = lastName;
    if (profileImage != null) _profileImage = profileImage;
    if (isLoading != null) _isLoading = isLoading;
    if (errorMessage != null) _errorMessage = errorMessage;

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
}
