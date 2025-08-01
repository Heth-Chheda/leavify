import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/network/perform_request.dart';

class UserRepository {
  final _api = PerformRequest();

  // MARK: UPLOAD PROFILE PICTURE
  Future<void> uploadProfileImage({required String profileImagePath}) async {
    try {
      final uploadProfileImageResponse = await _api.performRequest(
        url: ApiEndpoints.uploadProfileImage,
        method: RequestType.multipart,
        multipartFields: {},
        multipartFiles: {'profileImage': profileImagePath},
      );

      switch (uploadProfileImageResponse.statusCode) {
        case 200:
          // TODO: HANDLE THE SUCCESSFUL RESPONSE FOR UPLOADING THE IMAGE.
          break;

        case 400:
          throw Exception('Bad Request !!');

        case 401:
          throw Exception('Unauthorized: Please login again.');

        case 500:
          throw Exception('Server error: Please try again later.');

        default:
          throw Exception(
            'Unexpected error: ${uploadProfileImageResponse.statusCode}',
          );
      }
    } catch (e) {
      rethrow;
    }
    return;
  }
}
