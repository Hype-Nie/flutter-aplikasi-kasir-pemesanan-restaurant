import '../env/env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.baseUrl;
  static String get authToken => EnvConfig.authToken;
  static int get apiTimeout => EnvConfig.apiTimeout;
}
