import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';

class GetUserSummaryResponse {
  final User? currentUser;
  final List<LeaveDetailsWithoutLeaveId>? myUpcomingLeaves;
  final List<LeaveDetailsWithoutLeaveId>? teamUpcomingLeaves;
  final num? pendingLeavesFromTeam;

  GetUserSummaryResponse({
    this.currentUser,
    this.myUpcomingLeaves,
    this.teamUpcomingLeaves,
    this.pendingLeavesFromTeam,
  });

  factory GetUserSummaryResponse.fromJson(Map<String, dynamic> json) {
    return GetUserSummaryResponse(
      currentUser: json['currentUser'] != null
          ? User.fromJson(json['currentUser'])
          : null,
      myUpcomingLeaves: (json['myUpcomingLeaves'] as List<dynamic>?)
          ?.map((e) => LeaveDetailsWithoutLeaveId.fromJson(e))
          .toList(),
      teamUpcomingLeaves: (json['teamUpcomingLeaves'] as List<dynamic>?)
          ?.map((e) => LeaveDetailsWithoutLeaveId.fromJson(e))
          .toList(),
      pendingLeavesFromTeam: json['pendingLeavesFromTeam'] as num?,
    );
  }
  Map<String, dynamic> toJson() => {
    'currentUser': currentUser?.toJson(),
    'myUpcomingLeaves': myUpcomingLeaves?.map((e) => e.toJson()).toList(),
    'teamUpcomingLeaves': teamUpcomingLeaves?.map((e) => e.toJson()).toList(),
    'pendingLeavesFromTeam': pendingLeavesFromTeam,
  };
}
