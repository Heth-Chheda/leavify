class ApplyLeaveResponseModel {
  final bool? success;
  final String? leaveId;
  final String? error;

  ApplyLeaveResponseModel({this.success, this.leaveId, this.error});

  factory ApplyLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    return ApplyLeaveResponseModel(
      success: json['success'],
      leaveId: json['leaveId'],
      error: json['error'],
    );
  }
}
