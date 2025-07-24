import 'dart:convert';
import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import 'package:leavify/features/User/domain/request/apply_leave_request_model.dart';
import 'package:leavify/features/User/domain/response/apply_leave_response_model.dart';

class LeaveRepository {
  final _api = PerformRequest();

  Future<ApplyLeaveResponseModel> applyLeave(ApplyLeaveRequestModel request) async {
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
}
