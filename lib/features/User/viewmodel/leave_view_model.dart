import 'package:flutter/material.dart';
import 'package:leavify/features/User/data/leave_repository.dart';
import 'package:leavify/features/User/domain/request/apply_leave_request_model.dart';

class LeaveViewModel extends ChangeNotifier {
  final LeaveRepository _repository = LeaveRepository();

  bool isLoading = false;
  String? errorMessage;
  String? successLeaveId;

  Future<bool> submitLeaveRequest(ApplyLeaveRequestModel request) async {
    isLoading = true;
    notifyListeners();

    final response = await _repository.applyLeave(request);

    isLoading = false;
    if (response.success) {
      successLeaveId = response.leaveId;
      errorMessage = null;
      notifyListeners();
      return true;
    } else {
      errorMessage = response.error;
      successLeaveId = null;
      notifyListeners();
      return false;
    }
  }
}
