// This class will have the Login request model
class LoginRequest {
  final String? email;
  final String password;
  final String? phoneNumber;

  LoginRequest({this.email, this.phoneNumber, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'phoneNumber': phoneNumber,
    'password': password,
  };
}
