import 'package:leavify/features/Authentication/domain/leave.dart';
import 'package:leavify/features/Authentication/domain/user.dart';

class LoginResponseModel {
  final User? currentUser;
  final List<Leave>? myUpcomingLeaves;
  final List<Leave>? teamUpcomingLeaves;

  LoginResponseModel({
    this.currentUser,
    this.myUpcomingLeaves,
    this.teamUpcomingLeaves,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      currentUser: json['currentUser'] != null
          ? User.fromJson(json['currentUser'])
          : null,
      myUpcomingLeaves: (json['myUpcomingLeaves'] as List<dynamic>?)
          ?.map((e) => Leave.fromJson(e))
          .toList(),
      teamUpcomingLeaves: (json['teamUpcomingLeaves'] as List<dynamic>?)
          ?.map((e) => Leave.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    'currentUser': currentUser?.toJson(),
    'myUpcomingLeaves': myUpcomingLeaves?.map((e) => e.toJson()).toList(),
    'teamUpcomingLeaves': teamUpcomingLeaves?.map((e) => e.toJson()).toList(),
  };
}
