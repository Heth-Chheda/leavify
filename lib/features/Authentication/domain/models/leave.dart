class LeaveDetailsWithoutLeaveId {
  final String userId;
  final String employeeName;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? profileImageUrl;

  LeaveDetailsWithoutLeaveId({
    required this.userId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.profileImageUrl,
  });

  factory LeaveDetailsWithoutLeaveId.fromJson(Map<String, dynamic> json) =>
      LeaveDetailsWithoutLeaveId(
        userId: json['userId'] ?? '',
        employeeName: json['employeeName'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        reason: json['reason'] ?? '',
        status: json['status'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'employeeName': employeeName,
    'startDate': startDate,
    'endDate': endDate,
    'reason': reason,
    'status': status,
    'profileImageUrl': profileImageUrl,
  };
}
