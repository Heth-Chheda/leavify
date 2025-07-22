import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get baseUrl => dotenv.env['MOCK_BASE_URL'] ?? '';
}
