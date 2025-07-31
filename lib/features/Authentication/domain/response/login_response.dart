class LoginResponse {
  final bool success;
  final String? message;
  final String? userId;
  final String? jwtToken;

  LoginResponse({
    required this.success,
    this.message,
    this.userId,
    this.jwtToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      userId: json['userId'],
      jwtToken: json['jwtToken'],
    );
  }
}
