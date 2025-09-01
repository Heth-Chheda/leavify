class GeneralResponse {
  final bool? success;
  final String? message;
  final String? error;

  GeneralResponse({this.success, this.message, this.error});

  factory GeneralResponse.fromJson(Map<String, dynamic> json) {
    return GeneralResponse(
      success: json['success'],
      message: json['message'],
      error: json['error'],
    );
  }
}
