import 'package:leavify/core/config/app_environment.dart';

class ApiEndpoints {
  // Base Url
  static String baseUrl = AppEnvironment.baseUrl;

  // Authentication
  static final String login = '$baseUrl/auth/login';
  static final String register = '$baseUrl/auth/register';

  // User
  static final String getUserSummary = '$baseUrl/employee/summary';
  static final String uploadProfileImage = '$baseUrl/employee/upload-profile';
  static final String getWorkingDays = '$baseUrl/employee/workingdays';

  // Announcements
  static final String getAnnouncements = '$baseUrl/notifications/get';
  // only for specific users
  static final String sendAnnouncement = '$baseUrl/notifications/get';

  // Leaves
  static final String applyLeave = '$baseUrl/request/apply';
  static final String getMyLeaves = '$baseUrl/request/getmyleaves';
  static final String editMyLeave = '$baseUrl/request/edit';
  static final String sendReminderForLeave = '$baseUrl/request/sendReminder';
  static final String cancelLeave = '$baseUrl/request/cancel';

  // leave by id
  static final String getLeaveById = '$baseUrl/request/getleavesbyid';

  // Leaves // Manager
  static final String processLeave = '$baseUrl/request/process';
  static final String getPendingLeaves = '$baseUrl/request/getall';
}
