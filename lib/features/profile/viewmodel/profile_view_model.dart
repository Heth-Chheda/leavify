import 'package:flutter/cupertino.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
// import 'package:leavify/dummydata/leave/dummy_user_leaves.dart';
import 'package:leavify/features/Leave/data/leave_repository.dart';
import 'package:leavify/features/Leave/models/general/my_leaves.dart';
import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';
import 'package:leavify/features/Profile/data/models/get_user_reportees.dart';
import 'package:leavify/features/Profile/data/profile_repository.dart';

class ProfileViewModel extends BaseViewModel {
  final LeaveRepository _repository = LeaveRepository();
  final ProfileRepository _userRepository = ProfileRepository();

  LeaveData? _leaveData;
  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;
  LeaveData? get leaveData => _leaveData;
  String? _loadUserLeavesError;
  String? get loadUserLeavesError => _loadUserLeavesError;

  List<UserReportee> _userReportees = [];

  List<UserReportee> get userReportees => _userReportees;

  void resetEditMode() {
    _isEditMode = false;
    update(errorMessage: null);
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    update(errorMessage: null);
    notifyListeners();
  }

  Future<void> getEmployeeList(String userId) async {
    try {
      debugPrint('[VM] Fetching reportees for userId: $userId');
      update(isLoading: true, errorMessage: null);

      final reportees = await _userRepository.getUserReportees(userId: userId);

      debugPrint('[VM] API returned ${reportees.length} reportees');
      for (final r in reportees) {
        debugPrint(
          '[VM] Reportee → ${r.firstName} ${r.lastName} (${r.designation})',
        );
      }

      _userReportees = reportees;

      debugPrint('[VM] Stored reportees count: ${_userReportees.length}');
      update(isLoading: false);
    } catch (e) {
      debugPrint('[VM] Error fetching reportees: $e');
      update(errorMessage: e.toString(), isLoading: false);
    }
  }

  // MARK: LOAD USER LEAVES
  Future<void> loadUserLeaves(String userId) async {
    try {
      update(isLoading: true, errorMessage: null);
      _loadUserLeavesError = null;

      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
      _leaveData = await _repository.getUserLeaves(userId, accessToken);

      // _leaveData = dummyLeaveData;
      update(isLoading: false);
      notifyListeners();
    } catch (e) {
      update(errorMessage: e.toString(), isLoading: false);
      _loadUserLeavesError = e.toString();
      notifyListeners();
    }
  }

  void retry(String userId) {
    loadUserLeaves(userId);
  }

  // MARK: UPDATE LEAVE
  Future<bool> updateLeave({
    required String leaveId,
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
    bool? isCompOff,
    bool? isHalfDay,
    List<DateTime>? compDates,
    List<LeaveDocumentForApply>? documents,
    String? leaveType,
  }) async {
    update(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final updateData = <String, dynamic>{
        'leaveId': leaveId,
        'userId': userId,
      };

      // Add optional fields only if they are provided
      if (fromDate != null) {
        updateData['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        updateData['toDate'] = toDate.toIso8601String();
      }
      if (reason != null && reason.isNotEmpty) {
        updateData['reason'] = reason;
      }
      if (isCompOff != null) {
        updateData['isCompOff'] = isCompOff;
      }
      if (isHalfDay != null) {
        updateData['isHalfDay'] = isHalfDay;
      }
      if (compDates != null && compDates.isNotEmpty) {
        updateData['compDates'] = compDates
            .map((date) => date.toIso8601String())
            .toList();
      }
      if (documents != null) {
        updateData['documents'] = documents.map((doc) => doc.toJson()).toList();
      }
      if (leaveType != null && leaveType.isNotEmpty) {
        updateData['subType'] = leaveType.toUpperCase();
      }

      // Validate that at least one field is being updated
      final hasUpdates = updateData.keys.any(
        (key) => key != 'leaveId' && key != 'userId',
      );

      if (!hasUpdates) {
        update(
          errorMessage: 'At least one field must be updated',
          isLoading: false,
        );
        notifyListeners();
        return false;
      }

      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

      final response = await _repository.editUserLeave(updateData, accessToken);

      if (response.success == true) {
        _isEditMode = false;
      }

      _isEditMode = false;
      update(isLoading: false);
      notifyListeners();
      // return true;
      return response.success ?? false;
    } catch (e) {
      update(errorMessage: e.toString(), isLoading: false);
      notifyListeners();
      return false;
    }
  }

  // MARK: UPLOAD PROFILE IMAGE
  Future<bool> uploadProfileImage(String imagePath) async {
    update(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final result = await _userRepository.uploadProfileImage(
        profileImagePath: imagePath,
      );

      update(isLoading: false);
      notifyListeners();

      if (result.success == true) {
        return true;
      } else {
        // API responded but not successful
        throw Exception(result.message ?? "Failed to update profile image");
      }
    } catch (e) {
      update(errorMessage: e.toString(), isLoading: false);
      notifyListeners();
      return false;
    }
  }
}
