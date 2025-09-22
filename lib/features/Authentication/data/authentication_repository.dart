import 'package:leavify/base/base_repository.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';
import 'package:leavify/features/Leave/models/response/get_announcements_response.dart';
import 'package:leavify/features/Leave/models/response/get_working_days_response.dart';

import '../domain/request/login_request.dart';

class AuthenticationRepository extends BaseRepository {
  // MARK: - LOGIN
  Future<LoginResponse> login(LoginRequest request) async {
    final result = await performRequest(
      url: ApiEndpoints.login,
      method: HttpMethod.post,
      body: request.toJson(),
      fromJson: (json) => LoginResponse.fromJson(json),
    );

    if (result.success) {
      await AppStorage.saveBoolean('USER_IS_ALREADY_LOGGED_IN', true);
      await AppStorage.saveString('JWT_TOKEN', result.jwtToken ?? '');
      await AppStorage.saveString('USER_ID', result.userId ?? '');
    }

    return result;
  }

  // MARK: - GET USER SUMMARY
  Future<GetUserSummaryResponse> getUserSummary(String userId) async {
    final result = await performRequest(
      url: '${ApiEndpoints.getUserSummary}/$userId',
      method: HttpMethod.get,
      fromJson: (json) => GetUserSummaryResponse.fromJson(json),
    );

    return result;
  }

  // MARK: - GET ANNOUNCEMENTS
  Future<List<GetAnnouncementsResponse>> getAnnouncements() async {
    return await performRequest<List<GetAnnouncementsResponse>>(
      url: ApiEndpoints.getAnnouncements,
      method: HttpMethod.get,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map(
              (e) =>
                  GetAnnouncementsResponse.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  // MARK: - GET BALANCE
  Future<BalanceResponse> getLeaveBalance({required String userId}) async {
    return await performRequest(
      url: ApiEndpoints.getLeaveBalance,
      method: HttpMethod.post,
      body: {'userId': userId},
      fromJson: BalanceResponse.fromJson,
    );
  }
}
