/// Centralized route names used across the app.
/// Keeps navigation consistent & avoids typos.
class RouteNames {
  // 🔑 Authentication Flow
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  // 🏠 Leave Flow
  static const String applyLeave = '/apply-leave';
  static const String leaveDetail = '/leave-detail';
  static const String pendingRequests = '/pending-requests';
  static const String pendingRequestDetail = '/pending-request-detail';

  // 👤 Profile Flow
  static const String profile = '/profile';
  static const String userSettings = '/user-settings';
  static const String userMemberListScreen = '/user-member-list-screen';

  static const String otherUserProfile = '/other-user-profile';

  // 📊 Analytics Flow (future)
  static const String analytics = '/analytics';

  // ⚠️ Fallback / error
  static const String notFound = '/not-found';
}
