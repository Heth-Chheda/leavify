import 'package:leavify/base/base_repository.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Leave/models/general/my_leaves.dart';
import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';
import 'package:leavify/features/Leave/models/response/apply_leave_response_model.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';
import 'package:leavify/features/Leave/models/response/reportee_response.dart';
import 'package:leavify/features/Leave/models/response/send_reminder_response.dart';
import 'package:leavify/models/general_response.dart';

class LeaveRepository extends BaseRepository {
  Future<ApplyLeaveResponseModel> applyLeave(
    ApplyLeaveRequestModel request,
  ) async {
    return await performRequest(
      url: ApiEndpoints.applyLeave,
      method: HttpMethod.post,
      body: request.toJson(),
      fromJson: ApplyLeaveResponseModel.fromJson,
    );
  }

  // MARK: GET USER LEAVES
  Future<LeaveData> getUserLeaves(String userId) async {
    return await performRequest(
      url: ApiEndpoints.getMyLeaves,
      method: HttpMethod.post,
      fromJson: LeaveData.fromJson,
    );
  }

  // MARK: EDIT LEAVE
  Future<GeneralResponse> editUserLeave(
    Map<String, dynamic> requestBody,
  ) async {
    return await performRequest(
      url: ApiEndpoints.editMyLeave,
      method: HttpMethod.post,
      body: requestBody,
      fromJson: (json) => GeneralResponse.fromJson(json),
    );
  }

  // MARK: SEND REMINDER FOR LEAVE
  Future<SendReminderResponse> sendReminderForLeave({
    required String userId,
    required String leaveId,
  }) async {
    return await performRequest(
      url: ApiEndpoints.sendReminderForLeave,
      method: HttpMethod.post,
      body: {'userId': userId, 'leaveId': leaveId},
      fromJson: SendReminderResponse.fromJson,
    );
  }

  // MARK: CANCEL LEAVE
  Future<GeneralResponse> cancelLeave({
    required String leaveId,
    required String userId,
  }) async {
    return await performRequest(
      url: ApiEndpoints.cancelLeave,
      method: HttpMethod.post,
      body: {'userId': userId, 'leaveId': leaveId},
      fromJson: (json) => GeneralResponse.fromJson(json),
    );
  }

  // MARK: - ESCALATE LEAVES
  Future<GeneralResponse> escalateLeave({
    required String leaveId,
    required String userId,
  }) async {
    return await performRequest(
      url: ApiEndpoints.escalateLeave,
      method: HttpMethod.post,
      body: {'userId': userId, 'leaveId': leaveId},
      fromJson: (json) => GeneralResponse.fromJson(json),
    );
  }

  // MARK: MANAGER SPECIFIC FUNCTIONS
  // MARK: PROCESS LEAVES
  Future<GeneralResponse> processLeave({
    required String leaveId,
    required String status,
    required String actionTakenBy,
    required String comment,
  }) async {
    return await performRequest(
      url: ApiEndpoints.processLeave,
      method: HttpMethod.post,
      body: {
        'leaveId': leaveId,
        'status': status,
        'actionTakenBy': actionTakenBy,
        'comment': comment,
      },
      fromJson: (json) => GeneralResponse.fromJson(json),
    );
  }

  // MARK: GET PENDING LEAVES
  Future<List<GetAllResponse>> getPendingLeaves({
    required String userId,
  }) async {
    return await performRequest(
      url: ApiEndpoints.getPendingLeaves,
      method: HttpMethod.post,
      body: {'userId': userId},
      fromJson: (json) {
        final List<dynamic> data = json['leaves'] ?? [];
        return data.map((e) => GetAllResponse.fromJson(e)).toList();
      },
    );
  }

  // MARK: GET REPORTEES
  Future<ReporteesResponse> getReprtees({required String userId}) async {
    return await performRequest(
      url: ApiEndpoints.getReportees,
      method: HttpMethod.post,
      fromJson: ReporteesResponse.fromJson,
    );
  }

  // MARK: - GET LEAVE DETAIL BY ID
  Future<GetLeaveByIdResponse> getLeaveById({
    required String userId,
    required String leaveId,
  }) async {
    return await performRequest(
      url: ApiEndpoints.getLeaveById,
      method: HttpMethod.post,
      body: {'userId': userId, 'leaveId': leaveId},
      fromJson: GetLeaveByIdResponse.fromJson,
    );
  }

  // MARK: GET USER LEAVES
  Future<LeaveData> getEscalatedLeaves(String userId) async {
    return await performRequest(
      url: ApiEndpoints.getEscalatedLeaves,
      method: HttpMethod.post,
      body: {'userId': userId},
      fromJson: LeaveData.fromJson,
    );
  }

  // MARK: - PROCESS ESCALATED LEAVES
  Future<GeneralResponse> processEscalatedLeaves({
    required String userId,
    required String leaveId,
    required String comment,
  }) async {
    return await performRequest(
      url: ApiEndpoints.processEscalatedLeaves,
      method: HttpMethod.post,
      body: {'userId': userId, 'leaveId': leaveId, 'comment': comment},
      fromJson: (json) => GeneralResponse.fromJson(json),
    );
  }
}
