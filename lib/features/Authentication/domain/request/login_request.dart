// This class will have the Login request model
class LoginRequest {
  final String? username;
  final String password;

  LoginRequest({this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}
