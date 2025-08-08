import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';
import 'package:leavify/features/User/domain/response/get_announcements_response.dart';

import '../domain/request/login_request.dart';

class AuthenticationRepository {
  final PerformRequest _performRequest;

  AuthenticationRepository({PerformRequest? performRequest})
    : _performRequest = performRequest ?? PerformRequest();

  final get = RequestType.get;
  final post = RequestType.post;

  // MARK: - LOGIN
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _performRequest.performRequest(
        url: ApiEndpoints.login,
        method: post,
        body: request.toJson(),
      );
      // Handle response based on status code
      switch (response.statusCode) {
        case 200:
          // Only decode JSON for successful responses
          try {
            final Map<String, dynamic> data = jsonDecode(response.body);
            final loginResponse = LoginResponse.fromJson(data);
            debugPrint("Login Response: ${loginResponse.jwtToken}");
            debugPrint("Login Response: ${loginResponse.userId}");

            if (loginResponse.success) {
              AppStorage.saveBoolean('USER_IS_ALREADY_LOGGED_IN', true);
              AppStorage.saveString('JWT_TOKEN', loginResponse.jwtToken ?? '');
              AppStorage.saveString('USER_ID', loginResponse.userId ?? '');
            }
            return loginResponse;
          } catch (e) {
            // If JSON decode fails, create a generic error response
            throw Exception('Invalid response format from server');
          }

        case 400:
          // Try to get error message from response, fallback to generic message
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'Bad request';
          } catch (e) {
            // Response body is not JSON, use it as plain text or fallback
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Something went wrong please try again.';
          }
          throw Exception(errorMessage);

        case 401:
          // Try to get error message from response, fallback to generic message
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'Unauthorized access';
          } catch (e) {
            // Response body is not JSON, use it as plain text or fallback
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Unauthorized access.';
          }
          throw Exception(errorMessage);

        case 500:
          // Try to get error message from response, fallback to generic message
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'Internal server error';
          } catch (e) {
            // Response body is not JSON, use it as plain text or fallback
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Internal server error.';
          }
          throw Exception(errorMessage);

        default:
          // For any other status codes
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'Unexpected error occurred';
          } catch (e) {
            // Response body is not JSON, use it as plain text or fallback
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Unexpected error occurred';
          }
          throw Exception('$errorMessage (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: - GET USER SUMMARY
  Future<GetUserSummaryResponse> getUserSummary(String userId) async {
    try {
      final getUserSummaryResponse = await _performRequest.performRequest(
        url: '${ApiEndpoints.getUserSummary}/$userId',
        method: get,
      );

      switch (getUserSummaryResponse.statusCode) {
        case 200:
          try {
            final Map<String, dynamic> json = jsonDecode(
              getUserSummaryResponse.body,
            );
            return GetUserSummaryResponse.fromJson(json);
          } catch (e) {
            throw Exception('Invalid response format from server');
          }

        case 400:
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(
              getUserSummaryResponse.body,
            );
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'Bad request';
          } catch (e) {
            errorMessage = getUserSummaryResponse.body.isNotEmpty
                ? getUserSummaryResponse.body
                : 'Something went wrong. Please try logging in again.';
          }
          throw Exception(errorMessage);

        case 500:
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(
              getUserSummaryResponse.body,
            );
            errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'Internal server error';
          } catch (e) {
            errorMessage = getUserSummaryResponse.body.isNotEmpty
                ? getUserSummaryResponse.body
                : 'Internal server error. Please try again later.';
          }
          throw Exception(errorMessage);

        default:
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(
              getUserSummaryResponse.body,
            );
            errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'Unknown error occurred';
          } catch (e) {
            errorMessage = getUserSummaryResponse.body.isNotEmpty
                ? getUserSummaryResponse.body
                : 'Unknown error occurred';
          }
          throw Exception(
            '$errorMessage (${getUserSummaryResponse.statusCode})',
          );
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: - GET ANNOUNCEMENTS
  Future<List<GetAnnouncementsResponse>> getAnnouncements() async {
    try {
      final response = await _performRequest.performRequest(
        url: ApiEndpoints.getAnnouncements,
        method: get,
      );

      switch (response.statusCode) {
        case 200:
          try {
            final List<dynamic> jsonList = jsonDecode(response.body);
            return jsonList
                .map((json) => GetAnnouncementsResponse.fromJson(json))
                .toList();
          } catch (e) {
            throw Exception('Invalid response format from server');
          }

        case 400:
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'Bad request';
          } catch (e) {
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Something went wrong. Please try again.';
          }
          throw Exception(errorMessage);

        case 500:
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'Server error';
          } catch (e) {
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Internal server error. Please try again later.';
          }
          throw Exception(errorMessage);

        default:
          String errorMessage;
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          } catch (e) {
            errorMessage = response.body.isNotEmpty
                ? response.body
                : 'Unknown error occurred';
          }
          throw Exception('$errorMessage (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
