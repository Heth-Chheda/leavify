import 'package:leavify/features/Authentication/domain/response/login_response.dart';

/// Dummy JSON response for LoginResponse
const Map<String, dynamic> dummyLoginResponse = {
  "success": true,
  "message": "Login successful",
  "userId": "user_12345",
  "jwtToken":
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
      "eyJ1c2VySWQiOiJ1c2VyXzEyMzQ1Iiwicm9sZSI6ImVtcGxveWVlIn0."
      "abc123def456ghi789xyz",
  "error": null,
};

/// Converts dummy JSON into a Dart object
final LoginResponse dummyLoginData = LoginResponse.fromJson(dummyLoginResponse);
