import 'dart:convert';

import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';
import 'package:leavify/features/User/domain/request/apply_leave_request_model.dart';
import 'package:leavify/features/User/domain/response/apply_leave_response_model.dart';

class LeaveRepository {
  final _api = PerformRequest();

  // MARK: APPLY FOR LEAVE
  Future<ApplyLeaveResponseModel> applyLeave(
    ApplyLeaveRequestModel request,
  ) async {
    final response = await _api.performRequest(
      url: ApiEndpoints.applyLeave,
      method: RequestType.post,
      body: request.toJson(),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return ApplyLeaveResponseModel.fromJson(data);
    } else {
      return ApplyLeaveResponseModel(
        success: false,
        error: data['error'] ?? 'Unknown error occurred',
      );
    }
  }

  Future<LeaveData> getUserLeaves(String userId) async {
    try {
      final getUserLeavesResponse = await _api.performRequest(
        url: '${ApiEndpoints.getMyLeaves}/$userId',
        method: RequestType.get,
      );
      if (getUserLeavesResponse.statusCode == 200) {
        final jsonData = json.decode(getUserLeavesResponse.body);
        return LeaveData.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load leaves: ${getUserLeavesResponse.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: EDIT LEAVE
  Future<void> editUserLeave(Map<String, dynamic> requestBody) async {
    try {
      final response = await _api.performRequest(
        url: ApiEndpoints.editMyLeave,
        method: RequestType.post,
        body: requestBody,
      );

      final statusCode = response.statusCode;

      if (statusCode == 200) {
        // TODO: Handle successful edit leave response
        return;
      } else if (statusCode == 400) {
        throw Exception('Bad Request !!');
      } else if (statusCode == 401) {
        throw Exception('Unauthorized: Please login again.');
      } else if (statusCode == 500) {
        throw Exception('Server error: Please try again later.');
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
