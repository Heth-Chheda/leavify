import 'package:leavify/base/base_repository.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/features/Leave/models/request/add_announcement_request.dart';
import 'package:leavify/models/general_response.dart';

class ProfileRepository extends BaseRepository {
  // MARK: UPLOAD PROFILE PICTURE
  Future<GeneralResponse> uploadProfileImage({
    required String profileImagePath,
  }) async {
    return await performRequest<GeneralResponse>(
      url: ApiEndpoints.uploadProfileImage,
      method: HttpMethod.post,
      bodyType: BodyType.multipart,
      filePaths: {'profileImage': profileImagePath},
      fromJson: GeneralResponse.fromJson,
    );
  }

  // MARK: - MAKE ANNOUNCEMENT
  Future<GeneralResponse> addAnnouncement({
    required AddAnnouncementRequest request,
  }) async {
    return await performRequest<GeneralResponse>(
      url: ApiEndpoints.makeAnnouncement,
      method: HttpMethod.post,
      body: request.toJson(),
      fromJson: GeneralResponse.fromJson,
    );
  }
}
