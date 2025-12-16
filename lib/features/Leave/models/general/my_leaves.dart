// models/leave_model.dart
class MyLeaves {
  final String id;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;
  final bool isHalfDay;
  final bool isCompOff;
  final List<DateTime> compDates;
  final DateTime createdAt;
  final DateTime updatedAt;

  MyLeaves({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.isHalfDay,
    required this.isCompOff,
    required this.compDates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyLeaves.fromJson(Map<String, dynamic> json) {
    return MyLeaves(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      isHalfDay: json['isHalfDay'] ?? false,
      isCompOff: json['isCompOff'] ?? false,
      compDates:
          (json['compDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  int get durationInDays {
    final difference = toDate.difference(fromDate).inDays;
    return difference == 0 ? 1 : difference + 1;
  }
}

class LeaveData {
  final String userId;
  final num balanceLeaves;
  final num approvedLeaves;
  final num pendingLeaves;
  final num rejectedLeaves;
  final num cancelledLeaves;
  final List<MyLeaves> allLeaves;

  LeaveData({
    required this.userId,
    required this.balanceLeaves,
    required this.approvedLeaves,
    required this.pendingLeaves,
    required this.rejectedLeaves,
    required this.cancelledLeaves,
    required this.allLeaves,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      userId: json['userId'] ?? '',
      balanceLeaves: json['balanceLeaves'] ?? 0,
      approvedLeaves: json['approvedLeaves'] ?? 0,
      pendingLeaves: json['pendingLeaves'] ?? 0,
      rejectedLeaves: json['rejectedLeaves'] ?? 0,
      cancelledLeaves: json['cancelledLeaves'] ?? 0,
      allLeaves:
          (json['allLeaves'] as List<dynamic>?)
              ?.map((leave) => MyLeaves.fromJson(leave))
              .toList() ??
          [],
    );
  }
}
