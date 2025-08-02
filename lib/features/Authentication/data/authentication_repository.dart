import 'dart:convert';

import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';

import '../domain/request/login_request.dart';

class AuthenticationRepository {
  final PerformRequest _performRequest;

  AuthenticationRepository({PerformRequest? performRequest})
    : _performRequest = performRequest ?? PerformRequest();

  final get = RequestType.get;
  final post = RequestType.post;

  // MARK: LOGIN
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _performRequest.performRequest(
        url: ApiEndpoints.login,
        method: post,
        body: request.toJson(),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      // switch case for the response
      switch (response.statusCode) {
        case 200:
          final loginResponse = LoginResponse.fromJson(data);

          if (loginResponse.success) {
            AppStorage.saveBoolean('USER_IS_ALREADY_LOGGED_IN', true);
            AppStorage.saveString('JWT_TOKEN', loginResponse.jwtToken ?? '');
            AppStorage.saveString('USER_ID', loginResponse.userId ?? '');
          }
          return loginResponse;

        case 400:
          throw ('Something went wrong please try again.');

        case 401:
          throw ('Unauthorized access.');

        case 500:
          throw ('Internal server error.');

        default:
          throw Exception('Unexpected error occurred ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // MARK: GET USER SUMMARY
  Future<GetUserSummaryResponse> getUserSummary(String userId) async {
    try {
      final getUserSummaryResponse = await _performRequest.performRequest(
        url: '${ApiEndpoints.getUserSummary}/$userId',
        method: get,
      );
      switch (getUserSummaryResponse.statusCode) {
        case 200:
          final Map<String, dynamic> json = jsonDecode(
            getUserSummaryResponse.body,
          );
          return GetUserSummaryResponse.fromJson(json);

        case 400:
          throw ('Something went wrong. Please try logging in again.');

        case 500:
          throw ('Internal server error. Please try again later.');

        default:
          throw Exception(
            'Unknown error occurred ${getUserSummaryResponse.statusCode}',
          );
      }
    } catch (e) {
      rethrow;
    }
  }
}
