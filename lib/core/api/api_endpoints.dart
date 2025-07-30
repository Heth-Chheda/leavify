import 'package:leavify/core/config/app_environment.dart';

class ApiEndpoints {
  // Base Url
  static String baseUrl = AppEnvironment.baseUrl;

  // Authentication
  static final String login = '$baseUrl/auth/login';
  static final String register = '$baseUrl/auth/register';

  // User
  static final String getUserSummary = '$baseUrl/employee/summary';

  // Leaves
  static final String applyLeave = '$baseUrl/request/apply';
  static final String getMyLeaves = '$baseUrl/request/getmyleaves';
  static final String editMyLeave = '$baseUrl/request/edit';
}
