class UploadProfileImageResponse {
  final String status;
  final String message;
  final String? imageUrl;

  UploadProfileImageResponse({
    required this.status,
    required this.message,
    this.imageUrl,
  });

  factory UploadProfileImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadProfileImageResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}
