import 'package:leavify/features/Leave/models/general/leave_document.dart';

class GetLeaveByIdResponse {
  final String userId;
  final String leaveId;
  final String employeeName;
  final bool willComplete20Days;
  final int balanceLeaves;
  final LeaveDetails leaveDetails;
  final CurrentUserAction? currentUserAction;

  GetLeaveByIdResponse({
    required this.userId,
    required this.leaveId,
    required this.employeeName,
    required this.willComplete20Days,
    required this.balanceLeaves,
    required this.leaveDetails,
    this.currentUserAction,
  });

  factory GetLeaveByIdResponse.fromJson(Map<String, dynamic> json) {
    return GetLeaveByIdResponse(
      userId: json['userId'],
      leaveId: json['leaveId'],
      employeeName: json['employeeName'],
      willComplete20Days: json['willComplete20Days'],
      balanceLeaves: json['balanceLeaves'],
      leaveDetails: LeaveDetails.fromJson(json['leaveDetails']),
      currentUserAction: json['currentUserAction'] != null
          ? CurrentUserAction.fromJson(json['currentUserAction'])
          : null,
    );
  }
}

class CurrentUserAction {
  final String managerId;
  final String managerName;
  final String profileImageUrl;
  final String latestStatus;
  final String lastActionAt;
  final bool isPending;
  final bool isCurrentUser;

  CurrentUserAction({
    required this.managerId,
    required this.managerName,
    required this.profileImageUrl,
    required this.latestStatus,
    required this.lastActionAt,
    required this.isPending,
    required this.isCurrentUser,
  });

  factory CurrentUserAction.fromJson(Map<String, dynamic> json) {
    return CurrentUserAction(
      managerId: json['managerId'] ?? '',
      managerName: json['managerName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      latestStatus: json['latestStatus'] ?? '',
      lastActionAt: json['lastActionAt'] ?? '',
      isPending: json['isPending'] ?? false,
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

class LeaveDetails {
  final String type;
  final DateTime createdAt;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final List<LeaveDocument> documents;
  final bool isCompOff;
  final List<String> compDates;
  final bool isHalfDay;
  final String status;
  final bool isEscalated;
  final List<ReqStatusTracking> reqStatusTracking;
  final EscalationDet? escalationDet;
  final DateTime updatedAt;
  final ReminderDetails reminderDetails;

  LeaveDetails({
    required this.type,
    required this.createdAt,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.documents,
    required this.isCompOff,
    required this.compDates,
    required this.isHalfDay,
    required this.status,
    required this.isEscalated,
    required this.reqStatusTracking,
    this.escalationDet,
    required this.updatedAt,
    required this.reminderDetails,
  });

  factory LeaveDetails.fromJson(Map<String, dynamic> json) {
    return LeaveDetails(
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      reason: json['reason'],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((doc) => LeaveDocument.fromJson(doc))
              .toList() ??
          [],
      isCompOff: json['isCompOff'],
      compDates: List<String>.from(json['compDates'] ?? []),
      isHalfDay: json['isHalfDay'],
      status: json['status'],
      isEscalated: json['isEscalated'],
      reqStatusTracking:
          (json['reqStatusTracking'] as List?)
              ?.map((e) => ReqStatusTracking.fromJson(e))
              .toList() ??
          [],
      escalationDet: json['escalationDet'] != null
          ? EscalationDet.fromJson(json['escalationDet'])
          : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      reminderDetails: ReminderDetails.fromJson(json['reminderDetails']),
    );
  }
}

class ReqStatusTracking {
  final String status;
  final String processedBy;
  final DateTime processedAt;
  final String comment;

  ReqStatusTracking({
    required this.status,
    required this.processedBy,
    required this.processedAt,
    required this.comment,
  });

  factory ReqStatusTracking.fromJson(Map<String, dynamic> json) {
    return ReqStatusTracking(
      status: json['status'],
      processedBy: json['processedBy'],
      processedAt: DateTime.parse(json['processedAt']),
      comment: json['comment'],
    );
  }
}

class EscalationDet {
  final String? escalationStatus;
  final DateTime? escalatedDate;
  final DateTime? resolvedDate;
  final String? comments;

  EscalationDet({
    this.escalationStatus,
    this.escalatedDate,
    this.resolvedDate,
    this.comments,
  });

  factory EscalationDet.fromJson(Map<String, dynamic> json) {
    return EscalationDet(
      escalationStatus: json['escalationStatus'] as String?,
      escalatedDate: json['escalatedDate'] != null
          ? DateTime.tryParse(json['escalatedDate'])
          : null,
      resolvedDate: json['resolvedDate'] != null
          ? DateTime.tryParse(json['resolvedDate'])
          : null,
      comments: json['comments'] as String?,
    );
  }
}

class ReminderDetails {
  final DateTime reminderSentAt;
  final int reminderCount;

  ReminderDetails({required this.reminderSentAt, required this.reminderCount});

  factory ReminderDetails.fromJson(Map<String, dynamic> json) {
    return ReminderDetails(
      reminderSentAt: DateTime.parse(json['reminderSentAt']),
      reminderCount: json['reminderCount'],
    );
  }
}
