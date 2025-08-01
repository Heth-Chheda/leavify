class LoginResponse {
  final bool success;
  final String? message;
  final String? userId;
  final String? jwtToken;
  final String? error;

  LoginResponse({
    required this.success,
    this.message,
    this.userId,
    this.jwtToken,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      userId: json['userId'],
      jwtToken: json['jwtToken'],
      error: json['error'],
    );
  }
}
