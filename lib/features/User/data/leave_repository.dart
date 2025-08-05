import 'dart:convert';

import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';
import 'package:leavify/features/User/domain/request/apply_leave_request_model.dart';
import 'package:leavify/features/User/domain/response/apply_leave_response_model.dart';
import 'package:leavify/models/general_response.dart';

class LeaveRepository {
  final _api = PerformRequest();
  final post = RequestType.post;

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

  // MARK: GET USER LEAVES
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
  Future<GeneralResponse> editUserLeave(
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final response = await _api.performRequest(
        url: ApiEndpoints.editMyLeave,
        method: RequestType.post,
        body: requestBody,
      );

      final statusCode = response.statusCode;
      final jsonData = json.decode(response.body);

      if (statusCode == 200) {
        // TODO: Handle successful edit leave response
        return GeneralResponse.fromJson(jsonData);
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

  // MARK: SEND REMINDER FOR LEAVE
  Future<GeneralResponse> sendReminderForLeave({
    required String userId,
    required String leaveId,
  }) async {
    try {
      final sendReminderResponse = await _api.performRequest(
        url: ApiEndpoints.sendReminderForLeave,
        method: RequestType.post,
        body: {'userId': userId, 'leaveId': leaveId},
      );
      final jsonData = json.decode(sendReminderResponse.body);
      switch (sendReminderResponse.statusCode) {
        case 200:
          // TODO: HANDLE THE SUCCESSFUL RESPONSE FOR SENDING REMINDER
          return GeneralResponse.fromJson(jsonData);

        case 400:
          throw Exception(jsonData['error'] ?? 'Bad Request');

        case 401:
          throw Exception('Unauthorized: Please login again.');

        case 500:
          throw Exception('Server error: Please try again later.');

        default:
          throw Exception(
            'Unexpected error: ${sendReminderResponse.statusCode}',
          );
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: CANCEL LEAVE
  Future<GeneralResponse> cancelLeave({
    required String leaveId,
    required String userId,
  }) async {
    try {
      final cancelLeaveResponse = await _api.performRequest(
        url: ApiEndpoints.cancelLeave,
        method: post,
        body: {'leaveId': leaveId, 'userId': userId},
      );
      final jsonData = json.decode(cancelLeaveResponse.body);
      switch (cancelLeaveResponse.statusCode) {
        case 200:
          // TODO: HANDLE THE SUCCESSFUL RESPONSE FOR CANCEL LEAVE
          return GeneralResponse.fromJson(jsonData);
        case 400:
          throw Exception(jsonData['error'] ?? 'Bad Request');
        case 401:
          throw Exception('Unauthorized: Please login again.');
        case 500:
          throw Exception('Server error: Please try again later.');
        default:
          throw Exception(
            'Unexpected error: ${cancelLeaveResponse.statusCode}',
          );
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: MANAGER SPECIFIC FUNCTIONS
  // MARK: PROCESS LEAVES
  Future<GeneralResponse> processLeave({
    required String leaveId,
    required String status,
    required String
    actionTakenBy, // user_id of the manager or hr or super admin
  }) async {
    try {
      final processLeaveResponse = await _api.performRequest(
        url: ApiEndpoints.processLeave,
        method: RequestType.post,
        body: {
          'leaveId': leaveId,
          'status': status,
          'actionTakenBy': actionTakenBy,
          'comment': 'lhjaslfjhslfhjslfj',
        },
      );
      final jsonData = json.decode(processLeaveResponse.body);
      switch (processLeaveResponse.statusCode) {
        case 200:
          // TODO: HANDLE THE SUCCESSFUL RESPONSE FOR PROCESS LEAVE
          return GeneralResponse.fromJson(jsonData);

        case 400:
          throw Exception(jsonData['error'] ?? 'Bad Request');

        case 404:
          throw Exception('Unauthorized: Please login again.');

        case 500:
          throw Exception('Server error: Please try again later.');

        default:
          throw Exception(
            'Unexpected error: ${processLeaveResponse.statusCode}',
          );
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: GET PENDING LEAVES
  Future<List<GetAllResponse>> getPendingLeaves({
    required String userId,
  }) async {
    try {
      final response = await _api.performRequest(
        url: ApiEndpoints.getPendingLeaves,
        method: RequestType.post,
        body: {'userId': userId},
      );

      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(response.body);
          final result = data['result'] as List<dynamic>;

          final pendingLeaves = result
              .map((leaveJson) => GetAllResponse.fromJson(leaveJson))
              .toList();

          return pendingLeaves;

        case 400:
          throw Exception(
            "Bad Request: The server could not understand the request.",
          );
        case 401:
          throw Exception("Unauthorized: Please login again.");
        case 500:
          throw Exception("Server Error: Please try again later.");

        default:
          throw Exception("Unexpected Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
