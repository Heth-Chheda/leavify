import 'package:flutter/foundation.dart';
import 'package:leavify/features/User/data/leave_repository.dart';
import 'package:leavify/features/User/data/user_repository.dart';
import 'package:leavify/features/User/domain/models/leave_document.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';

enum ProfileViewState { loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final LeaveRepository _repository = LeaveRepository();
  final UserRepository _userRepository = UserRepository();

  ProfileViewState _state = ProfileViewState.loading;
  LeaveData? _leaveData;
  String? _errorMessage;
  bool _isEditMode = false;
  bool _isLoading = false;

  bool _useDummyData = true;

  bool get isLoading => _isLoading;
  bool get isEditMode => _isEditMode;
  ProfileViewState get state => _state;
  LeaveData? get leaveData => _leaveData;
  String? get errorMessage => _errorMessage;

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    _errorMessage = null;
    notifyListeners();
  }

  // MARK: LOAD USER LEAVES (WITH DUMMY DATA SUPPORT)
  Future<void> loadUserLeaves(String userId) async {
    _setState(ProfileViewState.loading);

    try {
      if (_useDummyData) {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 1500));

        _leaveData = _generateDummyLeaveData(userId);
        _setState(ProfileViewState.success);
      } else {
        // Use real API
        _leaveData = await _repository.getUserLeaves(userId);
        _setState(ProfileViewState.success);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ProfileViewState.error);
    }
  }

  void _setState(ProfileViewState newState) {
    _state = newState;
    notifyListeners();
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
    List<LeaveDocument>? documents,
  }) async {
    _isLoading = true;
    _errorMessage = null;
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
      if (documents != null && documents.isNotEmpty) {
        updateData['documents'] = documents.map((doc) => doc.toJson()).toList();
      }

      // Validate that at least one field is being updated
      final hasUpdates = updateData.keys.any(
        (key) => key != 'leaveId' && key != 'userId',
      );

      if (!hasUpdates) {
        _errorMessage = 'At least one field must be updated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await _repository.editUserLeave(updateData);

      // if (success) {
      //   _isEditMode = false;
      // }

      _isEditMode = false;
      _isLoading = false;
      notifyListeners();
      return true; // TODO: HANDLING THE RESPONSE
      // return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // MARK: UPLOAD PROFILE IMAGE
  Future<bool> uploadProfileImage(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.uploadProfileImage(profileImagePath: imagePath);
      _isLoading = false;

      // Optionally reload user data if needed here
      // await loadUserLeaves(userId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // MARK: DUMMY DATA GENERATOR
  LeaveData _generateDummyLeaveData(String userId) {
    final now = DateTime.now();

    // Generate dummy leave applications
    final dummyLeaves = [
      MyLeaves(
        id: 'leave_001',
        type: 'Annual Leave',
        fromDate: now.subtract(const Duration(days: 30)),
        toDate: now.subtract(const Duration(days: 28)),
        reason:
            'Family vacation to Goa. Planning to spend quality time with family and relax.',
        status: 'APPROVED',
        isHalfDay: false,
        isCompOff: false,
        compDates: [],
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(days: 32)),
      ),
      MyLeaves(
        id: 'leave_002',
        type: 'Sick Leave',
        fromDate: now.subtract(const Duration(days: 15)),
        toDate: now.subtract(const Duration(days: 15)),
        reason: 'Fever and cold symptoms. Doctor advised rest.',
        status: 'APPROVED',
        isHalfDay: true,
        isCompOff: false,
        compDates: [],
        createdAt: now.subtract(const Duration(days: 16)),
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
      MyLeaves(
        id: 'leave_003',
        type: 'Comp Off',
        fromDate: now.add(const Duration(days: 5)),
        toDate: now.add(const Duration(days: 5)),
        reason:
            'Compensatory off for working on weekend during project delivery.',
        status: 'PENDING',
        isHalfDay: false,
        isCompOff: true,
        compDates: [now.subtract(const Duration(days: 10))],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      MyLeaves(
        id: 'leave_004',
        type: 'Personal Leave',
        fromDate: now.add(const Duration(days: 20)),
        toDate: now.add(const Duration(days: 22)),
        reason: 'Attending cousin\'s wedding in Chennai.',
        status: 'PENDING',
        isHalfDay: false,
        isCompOff: false,
        compDates: [],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      MyLeaves(
        id: 'leave_005',
        type: 'Medical Leave',
        fromDate: now.subtract(const Duration(days: 60)),
        toDate: now.subtract(const Duration(days: 58)),
        reason: 'Regular health checkup and medical consultation.',
        status: 'REJECTED',
        isHalfDay: false,
        isCompOff: false,
        compDates: [],
        createdAt: now.subtract(const Duration(days: 65)),
        updatedAt: now.subtract(const Duration(days: 61)),
      ),
      MyLeaves(
        id: 'leave_006',
        type: 'Emergency Leave',
        fromDate: now.subtract(const Duration(days: 5)),
        toDate: now.subtract(const Duration(days: 5)),
        reason: 'Emergency at home, needed to take care of elderly parent.',
        status: 'APPROVED',
        isHalfDay: true,
        isCompOff: false,
        compDates: [],
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    // Calculate leave counts based on dummy data
    final approvedLeaves = dummyLeaves
        .where((leave) => leave.status == 'APPROVED')
        .length;
    final pendingLeaves = dummyLeaves
        .where((leave) => leave.status == 'PENDING')
        .length;
    final rejectedLeaves = dummyLeaves
        .where((leave) => leave.status == 'REJECTED')
        .length;

    return LeaveData(
      userId: userId,
      balanceLeaves: 18, // Remaining leave balance
      approvedLeaves: approvedLeaves,
      pendingLeaves: pendingLeaves,
      rejectedLeaves: rejectedLeaves,
      cancelledLeaves: 0,
      allLeaves: dummyLeaves,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
