import 'package:flutter/material.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';

class HomeViewModel extends ChangeNotifier {
  LoginResponseModel? _homeData;
  bool _isLoading = true;
  String? _error;

  // Getters
  LoginResponseModel? get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // User specific getters for easy access
  String get userName => _homeData?.currentUser?.firstName ?? 'User';
  String get userFullName =>
      '${_homeData?.currentUser?.firstName ?? ''} ${_homeData?.currentUser?.lastName ?? ''}'
          .trim();
  String get userEmail => _homeData?.currentUser?.email ?? '';
  String get userMobile => _homeData?.currentUser?.mobile ?? '';
  int get leaveBalance => _homeData?.currentUser?.balance ?? 0;
  int get approvedLeaves => _homeData?.currentUser?.approved ?? 0;
  int get rejectedLeaves => _homeData?.currentUser?.rejected ?? 0;
  int get pendingLeaves => _homeData?.currentUser?.pending ?? 0;

  // Initialize and load data
  Future<void> initialize() async {
    await loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      // Get user data from SharedPreferences
      final userData = await AppStorage.getObject<LoginResponseModel>(
        "user_details",
        (json) => LoginResponseModel.fromJson(json),
      );

      if (userData != null) {
        _homeData = userData;
      } else {
        _error = "No user data found";
      }
    } catch (e) {
      _error = "Failed to load user data: $e";
      debugPrint("HomeViewModel error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadHomeData();
  }

  // Get upcoming leaves for current user
  List<Leave> get myUpcomingLeaves => _homeData?.myUpcomingLeaves ?? [];

  // Get team upcoming leaves
  List<Leave> get teamUpcomingLeaves => _homeData?.teamUpcomingLeaves ?? [];

  // Get all upcoming leaves (my + team)
  List<Leave> get allUpcomingLeaves {
    final all = <Leave>[];
    all.addAll(myUpcomingLeaves);
    all.addAll(teamUpcomingLeaves);
    return all;
  }

  // Check if user has any upcoming leaves
  bool get hasUpcomingLeaves => myUpcomingLeaves.isNotEmpty;

  // Check if team has any upcoming leaves
  bool get hasTeamUpcomingLeaves => teamUpcomingLeaves.isNotEmpty;
}
