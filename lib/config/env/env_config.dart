import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get authToken => dotenv.env['AUTH_TOKEN'] ?? '';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;
  static String get appName => dotenv.env['APP_NAME'] ?? '';
  static bool get appDebug => dotenv.env['APP_DEBUG']?.toLowerCase() == 'true';
}
