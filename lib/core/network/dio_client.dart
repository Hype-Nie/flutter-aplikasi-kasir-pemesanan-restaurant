import 'package:dio/dio.dart';

import '../../config/env/env_config.dart';
import 'api_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _create();
    return _instance!;
  }

  static Dio _create() {
    final dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(AuthInterceptor());

    return dio;
  }

  static void reset() {
    _instance = null;
  }
}
