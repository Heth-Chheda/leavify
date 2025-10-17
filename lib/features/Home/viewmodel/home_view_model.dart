import 'package:flutter/material.dart';
import 'package:leavify/core/storage/app_storage.dart';
// import 'package:leavify/dummydata/announcement/announcement.dart';
// import 'package:leavify/dummydata/users/balance_leaves.dart';
// import 'package:leavify/dummydata/users/hr.dart';
// import 'package:leavify/dummydata/users/employer.dart';
// import 'package:leavify/dummydata/users/manager.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/response/get_category_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_holiday_list_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Leave/models/response/get_announcements_response.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  GetUserSummaryResponse? _homeData;
  bool _isLoading = true;
  String? _error;

  // MARK: - New: Leave Categories
  LeaveCategoryResponse? _leaveCategoryResponse;
  List<LeaveCategory> _leaveCategories = [];
  List<LeaveCategory> get leaveCategories => _leaveCategories;

  // MARK: HOLIDAY
  GetHolidayListResponse? _holidayListResponse;
  GetHolidayListResponse? get holidayListResponse => _holidayListResponse;

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
  String get designation => _homeData?.currentUser?.designation ?? '';

  // working days
  int _leaveBalance = 0;
  int _workingDays = 0;

  // working day getters
  int get leaveBalance => _leaveBalance;
  int get workingDays => _workingDays;

  Future<void> initialize() async {
    await _getHolidayList();
    await _loadUserSummaryFromApi();
    await _fetchAnnouncements();
    // await _getLeaveBalance();
  }

  Future<void> _loadUserSummaryFromApi() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Replace with actual user ID (ideally get from AppStorage or token decoding)
      final userId = await AppStorage.getString("USER_ID") ?? "";
      final response = await _authenticationRepository.getUserSummary(userId);
      // final response = dummyManagerData;
      // final response = dummyEmployeeData;
      // final response = dummyHRData;

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
    _isLoading = false;
    _error = null;

    notifyListeners();
  }

  // MARK: - GET LEAVE BALANCE
  Future<void> getLeaveBalance() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = await AppStorage.getString("USER_ID") ?? "";
      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
      final result = await _authenticationRepository.getLeaveBalance(
        userId: userId,
        accessToken: accessToken,
      );
      // final result = dummyBalanceData;

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

  // MARK: - FETCH ANNOUNCEMENTS
  Future<void> _fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _authenticationRepository.getAnnouncements();
      // _announcements = dummyAnnouncements;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - GET CATEGORY
  // MANAGER, HR, ADMIN AND SUPER ADMIN FUNCTIONALITY.
  Future<void> getCategory() async {
    try {
      _isLoading = true;
      notifyListeners();

      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
      _leaveCategoryResponse = await _authenticationRepository.getCategory(
        accessToken: accessToken,
      );

      _leaveCategories = _leaveCategoryResponse?.categories ?? [];
    } catch (e) {
      _error = "Failed to fetch leave categories: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - Fetch Holiday List
  Future<void> _getHolidayList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _holidayListResponse = await _authenticationRepository.getHolidayList();
    } catch (e) {
      _error = "Failed to fetch holiday list: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: REFRESH
  Future<void> refresh() async {
    await _loadUserSummaryFromApi();
    await _fetchAnnouncements();
    await _getHolidayList();
    // await _getLeaveBalance();
  }

  List<LeaveDetailsWithoutLeaveId> get myUpcomingLeaves =>
      _homeData?.myUpcomingLeaves ?? [];
  List<LeaveDetailsWithoutLeaveId> get teamUpcomingLeaves =>
      _homeData?.teamUpcomingLeaves ?? [];

  List<LeaveDetailsWithoutLeaveId> get allUpcomingLeaves {
    final all = <LeaveDetailsWithoutLeaveId>[];
    all.addAll(myUpcomingLeaves);
    all.addAll(teamUpcomingLeaves);
    return all;
  }

  bool get hasUpcomingLeaves => myUpcomingLeaves.isNotEmpty;
  bool get hasTeamUpcomingLeaves => teamUpcomingLeaves.isNotEmpty;
}
