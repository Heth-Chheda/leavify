import 'package:leavify/core/config/app_environment.dart';

class ApiEndpoints {
  // Base Url
  static String baseUrl = AppEnvironment.baseUrl;

  // Authentication
  static final String login = '$baseUrl/auth/login';
  static final String register = '$baseUrl/auth/register';

  // Leaves
  static final String applyLeave = '$baseUrl/api/applyLeave';
}
