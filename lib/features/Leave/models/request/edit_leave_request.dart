import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';

class EditLeaveRequest {
  final String leaveId;
  final String userId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? reason;
  final bool? isCompOff;
  final bool? isHalfDay;
  final List<String>? compDates;
  final List<LeaveDocument>? documents;

  EditLeaveRequest({
    required this.leaveId,
    required this.userId,
    this.fromDate,
    this.toDate,
    this.reason,
    this.isCompOff,
    this.isHalfDay,
    this.compDates,
    this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'leaveId': leaveId,
      'userId': userId,
      if (fromDate != null) 'fromDate': fromDate!.toIso8601String(),
      if (toDate != null) 'toDate': toDate!.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (isCompOff != null) 'isCompOff': isCompOff,
      if (isHalfDay != null) 'isHalfDay': isHalfDay,
      if (compDates != null) 'compDates': compDates,
      if (documents != null)
        'documents': documents!.map((doc) => doc.toJson()).toList(),
    };
  }
}
