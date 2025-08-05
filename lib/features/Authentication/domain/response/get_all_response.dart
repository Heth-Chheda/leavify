class GetAllResponse {
  final String profileImage;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;

  GetAllResponse({
    required this.profileImage,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  factory GetAllResponse.fromJson(Map<String, dynamic> json) {
    return GetAllResponse(
      profileImage: json['profileImage'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
