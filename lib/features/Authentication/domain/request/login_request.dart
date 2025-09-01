// This class will have the Login request model
// login type
// username
// password
// fcm token
class LoginRequest {
  final String? username;
  final String loginType;
  final String password;
  final String fcmToken;

  LoginRequest({
    this.username,
    required this.loginType,
    required this.fcmToken,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'userName': username,
    'password': password,
    'loginType': loginType,
    'fcmToken': fcmToken,
  };
}
