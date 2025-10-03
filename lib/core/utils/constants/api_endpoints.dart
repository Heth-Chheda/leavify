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
  static final String getLeaveBalance = '$baseUrl/employee/workingdays';

  // Announcements
  static final String getAnnouncements = '$baseUrl/notifications/get';
  static final String makeAnnouncement = '$baseUrl/notifications/add';
  // only for specific users
  static final String sendAnnouncement = '$baseUrl/notifications/get';

  // Leaves
  static final String applyLeave = '$baseUrl/request/apply';
  static final String getMyLeaves = '$baseUrl/request/getmyleaves';
  static final String editMyLeave = '$baseUrl/request/edit';
  static final String sendReminderForLeave = '$baseUrl/request/sendReminder';
  static final String cancelLeave = '$baseUrl/request/cancel';
  static final String getReportees = '$baseUrl/request/getreportees';

  // leave by id
  static final String getLeaveById = '$baseUrl/request/getleavesbyid';

  // escalate
  static final String escalateLeave = '$baseUrl/request/escalate';
  static final String getEscalatedLeaves = '$baseUrl/request/getescalated';
  static final String processEscalatedLeaves =
      '$baseUrl/request/processescalated';

  // Leaves // Manager
  static final String processLeave = '$baseUrl/request/process';
  static final String getPendingLeaves = '$baseUrl/request/getall';
}
