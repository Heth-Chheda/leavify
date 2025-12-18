import 'package:flutter/cupertino.dart';
import 'package:leavify/base/base_repository.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Authentication/domain/response/get_category_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_holiday_list_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Leave/models/response/get_announcements_response.dart';

class HomeViewModel extends BaseViewModel {
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

  // Other user
  GetUserSummaryResponse? _otherUserData;
  User? get otherUser => _otherUserData?.currentUser;
  GetUserSummaryResponse? get otherUserData => _otherUserData;

  // User-specific getters
  String get userName => _homeData?.currentUser?.firstName ?? 'User';
  String get userFullName =>
      '${_homeData?.currentUser?.firstName ?? ''} ${_homeData?.currentUser?.lastName ?? ''}'
          .trim();
  String get userEmail => _homeData?.currentUser?.email ?? '';
  String get userRole => _homeData?.currentUser?.role ?? '';
  num get approvedLeaves => _homeData?.currentUser?.approved ?? 0;
  num get rejectedLeaves => _homeData?.currentUser?.rejected ?? 0;
  num get pendingLeaves => _homeData?.currentUser?.pending ?? 0;
  String get profileImageUrl => _homeData?.currentUser?.profileImageUrl ?? '';
  bool get canSendAnnouncement =>
      _homeData?.currentUser?.canSendAnnouncement ?? false;
  String get designation => _homeData?.currentUser?.designation ?? '';

  // working days
  num _leaveBalance = 0;
  num _workingDays = 0;

  // working day getters
  num get leaveBalance => _leaveBalance;
  num get workingDays => _workingDays;

  Future<void> initialize() async {
    await loadUserSummaryFromApi();
    await _getHolidayList();
    await _fetchAnnouncements();
    // await _getLeaveBalance();
  }

  // MARK: - ERROR CLEANER HELPER
  String _cleanErrorMessage(dynamic e) {
    if (e is ApiException) {
      // Filter out technical jargon if it slipped into the message
      if (e.message.contains("ClientException") ||
          e.message.contains("uri=") ||
          e.message.contains("Client is already closed")) {
        return "Network request failed. Please retry.";
      }
      return e.message;
    }
    // Fallback for non-ApiExceptions (crashes, parsing errors)
    return "Something went wrong";
  }

  // MARK: - LOAD USER SUMMARY
  Future<void> loadUserSummaryFromApi({String? userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final targetUserId =
          userId ?? await AppStorage.getString("USER_ID") ?? "";
      final response = await _authenticationRepository.getUserSummary(
        targetUserId,
      );

      if (userId != null) {
        _otherUserData = response;
      } else {
        _homeData = response;
      }
      if (userId == null) {
        await AppStorage.saveObject("user_details", response.toJson());
      }
    } catch (e) {
      _error = _cleanErrorMessage(e);
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

      if (userId.isEmpty) {
        debugPrint("⚠️ LEAVE_BALANCE: Warning! UserID is empty.");
      }

      debugPrint("🔵 LEAVE_BALANCE: Calling API getLeaveBalance...");
      final result = await _authenticationRepository.getLeaveBalance(
        userId: userId,
        accessToken: accessToken,
      );

      _leaveBalance = result.balance ?? 0;
      _workingDays = result.remainingWorkingDays ?? 0;
    } catch (e) {
      _error = _cleanErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("🔵 LEAVE_BALANCE: Process complete. Loading set to false.");
    }
  }

  // MARK: - FETCH ANNOUNCEMENTS
  Future<void> _fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _authenticationRepository.getAnnouncements();
    } catch (e) {
      _error = _cleanErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - GET CATEGORY
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
      _error = _cleanErrorMessage(e);
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
      _error = _cleanErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: REFRESH
  Future<void> refresh() async {
    await loadUserSummaryFromApi();
    await _fetchAnnouncements();
    await _getHolidayList();
    // await _getLeaveBalance();
  }

  // MARK: - LOGOUT
  Future<bool> logout() async {
    final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
    return await _authenticationRepository.logout(accessToken: accessToken);
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

  List<DateTime> generateDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime current = start;

    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  List<DateTime> get upcomingLeaveDates {
    List<DateTime> dates = [];

    for (var leave in myUpcomingLeaves) {
      final start = DateTime.parse(leave.startDate);
      final end = DateTime.parse(leave.endDate);

      dates.addAll(generateDateRange(start, end));
    }

    return dates;
  }
}
