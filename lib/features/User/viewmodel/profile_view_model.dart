import 'package:flutter/foundation.dart';
import 'package:leavify/features/User/data/leave_repository.dart';
import 'package:leavify/features/User/domain/models/leave_document.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';

enum ProfileViewState { loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final LeaveRepository _repository = LeaveRepository();

  ProfileViewState _state = ProfileViewState.loading;
  LeaveData? _leaveData;
  String? _errorMessage;
  bool _isEditMode = false;
  bool _isLoading = false;

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

  Future<void> loadUserLeaves(String userId) async {
    _setState(ProfileViewState.loading);

    try {
      _leaveData = await _repository.getUserLeaves(userId);
      _setState(ProfileViewState.success);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
