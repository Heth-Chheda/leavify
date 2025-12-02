import 'package:leavify/base/base_repository.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';
import 'package:leavify/features/Authentication/domain/response/get_category_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_holiday_list_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';
import 'package:leavify/features/Authentication/domain/response/version_response.dart';
import 'package:leavify/features/Leave/models/response/get_announcements_response.dart';
import 'package:leavify/features/Leave/models/response/get_working_days_response.dart';

import '../domain/request/login_request.dart';

class AuthenticationRepository extends BaseRepository {

  // MARK: VERSION INFO
  Future<VersionResponse> getVersionInfo () async {
    return await performRequest(
        url: ApiEndpoints.versionCheck,
        method: HttpMethod.get,
        fromJson: VersionResponse.fromJson
    );
  }

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
    return await performListRequest<GetAnnouncementsResponse>(
      url: ApiEndpoints.getAnnouncements,
      method: HttpMethod.get,
      fromJson: (json) => GetAnnouncementsResponse.fromJson(json),
    );
  }

  // MARK: - GET BALANCE
  Future<BalanceResponse> getLeaveBalance({
    required String userId,
    required String accessToken,
  }) async {
    return await performRequest(
      url: ApiEndpoints.getLeaveBalance,
      method: HttpMethod.post,
      body: {'userId': userId},
      accessToken: accessToken,
      fromJson: BalanceResponse.fromJson,
    );
  }

  // MARK: GET CATEGORY
  Future<LeaveCategoryResponse> getCategory({
    required String accessToken,
  }) async {
    return await performRequest(
      url: ApiEndpoints.getCategory,
      method: HttpMethod.get,
      accessToken: accessToken,
      fromJson: LeaveCategoryResponse.fromJson,
    );
  }

  // MARK: HOLIDAYS LIST
  Future<GetHolidayListResponse> getHolidayList() async {
    return await performRequest(
      url: ApiEndpoints.getHolidayList,
      method: HttpMethod.get,
      fromJson: GetHolidayListResponse.fromJson,
    );
  }

  // MARK: - LOGOUT
  Future<bool> logout({required String accessToken}) async {
    try {
      await performRequest<Map<String, dynamic>>(
        url: ApiEndpoints.logout,
        method: HttpMethod.post,
        accessToken: accessToken,
        fromJson: (json) => json,
      );
      // If we reach here, performRequest didn't throw → means 2xx response
      return true;
    } on ApiException {
      return false;
    } catch (e) {
      return false;
    }
  }
}
