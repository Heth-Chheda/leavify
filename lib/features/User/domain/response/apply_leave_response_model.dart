class ApplyLeaveResponseModel {
  final bool success;
  final String? leaveId;
  final String? error;

  ApplyLeaveResponseModel({required this.success, this.leaveId, this.error});

  factory ApplyLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    return ApplyLeaveResponseModel(
      success: json['success'] ?? false,
      leaveId: json['leaveId'],
      error: json['error'],
    );
  }
}
