import 'dart:convert';
import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';
import '../domain/request/login_request.dart';
import '../domain/response/login_response.dart';

class AuthenticationRepository {
  final PerformRequest _performRequest;

  AuthenticationRepository({PerformRequest? performRequest})
    : _performRequest = performRequest ?? PerformRequest();

  Future<LoginResponseModel> login(LoginRequest request) async {
    try {
      final response = await _performRequest.performRequest(
        url: ApiEndpoints.login,
        method: RequestType.post,
        body: request.toJson(),
      );

      final Map<String, dynamic> json = jsonDecode(response.body);
      return LoginResponseModel.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }
}
