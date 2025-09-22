import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Leave/models/request/add_announcement_request.dart';
import 'package:leavify/features/Profile/data/profile_repository.dart';
import 'package:leavify/models/general_response.dart';

class AnnouncementViewModel extends BaseViewModel {
  final ProfileRepository _repository = ProfileRepository();

  GeneralResponse? latestAnnouncement;

  // MARK: - UTILITY METHODS
  Future<String?> _loadUserId() async {
    final user = await AppStorage.getObject<GetUserSummaryResponse>(
      "user_details",
      (json) => GetUserSummaryResponse.fromJson(json),
    );
    return user?.currentUser?.id;
  }

  // MARK: - ADD ANNOUNCEMENT
  Future<bool> addAnnouncement(String title, String body) async {
    try {
      update(isLoading: true, errorMessage: null);
      notifyListeners();

      final userId = await _loadUserId();
      final request = AddAnnouncementRequest(
        title: title,
        body: body,
        type: 'ANNOUNCEMENT',
        sentBy: userId,
      );

      final response = await _repository.addAnnouncement(request: request);
      latestAnnouncement = response;

      update(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      update(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }
}
