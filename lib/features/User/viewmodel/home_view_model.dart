import 'package:flutter/material.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  GetUserSummaryResponse? _homeData;
  bool _isLoading = true;
  String? _error;

  // Getters
  GetUserSummaryResponse? get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // User-specific getters
  String get userName => _homeData?.currentUser?.firstName ?? 'User';
  String get userFullName =>
      '${_homeData?.currentUser?.firstName ?? ''} ${_homeData?.currentUser?.lastName ?? ''}'
          .trim();
  String get userEmail => _homeData?.currentUser?.email ?? '';
  int get leaveBalance => _homeData?.currentUser?.balance ?? 0;
  int get approvedLeaves => _homeData?.currentUser?.approved ?? 0;
  int get rejectedLeaves => _homeData?.currentUser?.rejected ?? 0;
  int get pendingLeaves => _homeData?.currentUser?.pending ?? 0;

  Future<void> initialize() async {
    await _loadUserSummaryFromApi();
  }

  Future<void> _loadUserSummaryFromApi() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Replace with actual user ID (ideally get from AppStorage or token decoding)
      const userId = '6877b8beae03e3763635516d';
      final response = await _authenticationRepository.getUserSummary(userId);

      _homeData = response;
      await AppStorage.saveObject("user_details", response.toJson());
    } catch (e) {
      _error = "Failed to load user data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadUserSummaryFromApi();
  }

  List<Leave> get myUpcomingLeaves => _homeData?.myUpcomingLeaves ?? [];
  List<Leave> get teamUpcomingLeaves => _homeData?.teamUpcomingLeaves ?? [];

  List<Leave> get allUpcomingLeaves {
    final all = <Leave>[];
    all.addAll(myUpcomingLeaves);
    all.addAll(teamUpcomingLeaves);
    return all;
  }

  bool get hasUpcomingLeaves => myUpcomingLeaves.isNotEmpty;
  bool get hasTeamUpcomingLeaves => teamUpcomingLeaves.isNotEmpty;
}
