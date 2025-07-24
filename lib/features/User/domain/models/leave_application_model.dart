enum LeaveStatus { pending, approved, rejected, escalated }

class LeaveApplication {
  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime appliedDate;
  final String? approverName;
  final String? comments;
  final String? employeeName;
  final String? employeeId;
  final String? department;
  final List<String>? attachments;
  final DateTime? reviewedDate;

  LeaveApplication({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.approverName,
    this.comments,
    this.employeeName,
    this.employeeId,
    this.department,
    this.attachments,
    this.reviewedDate,
  });
}