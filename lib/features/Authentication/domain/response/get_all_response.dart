class GetAllResponse {
  final String profileImage;
  final String firstName;
  final String lastName;
  final String role;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String leaveId;
  final bool escalated;
  final int documentsCount;
  final String? designation;

  GetAllResponse({
    required this.profileImage,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.leaveId,
    required this.escalated,
    required this.documentsCount,
    this.designation,
  });

  factory GetAllResponse.fromJson(Map<String, dynamic> json) {
    return GetAllResponse(
      profileImage: json['profileImage'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      startDate: json['startDate'],
      endDate: json['endDate'],
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      leaveId: json['leaveId'] ?? '',
      escalated: json['escalated'] ?? false,
      documentsCount: json['documentsCount'] ?? 0,
      designation: json['designation'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'profileImage': profileImage,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'startDate': startDate,
    'endDate': endDate,
    'reason': reason,
    'status': status,
    'leaveId': leaveId,
    'escalated': escalated,
    'documentsCount': documentsCount,
    'designation': designation,
  };
}
