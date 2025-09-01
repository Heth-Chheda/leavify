import 'dart:convert';

import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import 'package:leavify/features/User/domain/request/add_announcement_request.dart';
import 'package:leavify/models/general_response.dart';

class UserRepository {
  final _api = PerformRequest();

  // MARK: UPLOAD PROFILE PICTURE
  Future<GeneralResponse> uploadProfileImage({
    required String profileImagePath,
  }) async {
    try {
      final response = await _api.performRequest(
        url: ApiEndpoints.uploadProfileImage,
        method: RequestType.multipart,
        multipartFields: {},
        multipartFiles: {'profileImage': profileImagePath},
      );

      switch (response.statusCode) {
        case 200:
          // Parse JSON and return as GeneralResponse
          final data = jsonDecode(response.body);
          return GeneralResponse.fromJson(data);

        case 400:
          return GeneralResponse(success: false, message: 'Bad Request !!');

        case 401:
          return GeneralResponse(
            success: false,
            message: 'Unauthorized: Please login again.',
          );

        case 500:
          return GeneralResponse(
            success: false,
            message: 'Server error: Please try again later.',
          );

        default:
          return GeneralResponse(
            success: false,
            message: 'Unexpected error: ${response.statusCode}',
          );
      }
    } catch (e) {
      return GeneralResponse(success: false, message: e.toString());
    }
  }

  // MARK: - MAKE ANNOUNCEMENT
  Future<GeneralResponse> addAnnouncement({
    required AddAnnouncementRequest request,
  }) async {
    try {
      final response = await _api.performRequest(
        url: ApiEndpoints.makeAnnouncement,
        method: RequestType.post,
        body: request.toJson(),
      );

      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(response.body);
          return GeneralResponse.fromJson(data);

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
