import 'package:flutter/material.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/User/domain/response/get_announcements_response.dart';

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
  List<GetAnnouncementsResponse> _announcements = [];
  List<GetAnnouncementsResponse> get announcements => _announcements;

  // User-specific getters
  String get userName => _homeData?.currentUser?.firstName ?? 'User';
  String get userFullName =>
      '${_homeData?.currentUser?.firstName ?? ''} ${_homeData?.currentUser?.lastName ?? ''}'
          .trim();
  String get userEmail => _homeData?.currentUser?.email ?? '';
  String get userRole => _homeData?.currentUser?.role ?? '';
  int get approvedLeaves => _homeData?.currentUser?.approved ?? 0;
  int get rejectedLeaves => _homeData?.currentUser?.rejected ?? 0;
  int get pendingLeaves => _homeData?.currentUser?.pending ?? 0;
  String get profileImageUrl => _homeData?.currentUser?.profileImageUrl ?? '';
  bool get canSendAnnouncement =>
      _homeData?.currentUser?.canSendAnnouncement ?? false;

  // working days
  int _leaveBalance = 0;
  int _workingDays = 0;

  // working day getters
  int get leaveBalance => _leaveBalance;
  int get workingDays => _workingDays;

  Future<void> initialize() async {
    await _loadUserSummaryFromApi();
    await _fetchAnnouncements();
    await _getLeaveBalance();
  }

  Future<void> _loadUserSummaryFromApi() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Replace with actual user ID (ideally get from AppStorage or token decoding)
      final userId = await AppStorage.getString("USER_ID") ?? "";
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

  /// Clear all data when logging out
  void clearData() {
    _homeData = null;
    _announcements = [];
    _leaveBalance = 0;
    _workingDays = 0;
    _isLoading = true;
    _error = null;

    notifyListeners();
  }

  // MARK: - GET LEAVE BALANCE
  Future<void> _getLeaveBalance() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = await AppStorage.getString("USER_ID") ?? "";
      final result = await _authenticationRepository.getLeaveBalance(
        userId: userId,
      );

      // Update from API response
      _leaveBalance = result.balance ?? 0;
      _workingDays = result.remainingWorkingDays ?? 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void>  _fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _authenticationRepository.getAnnouncements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadUserSummaryFromApi();
    await _fetchAnnouncements();
    await _getLeaveBalance();
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
