import 'package:dio/dio.dart';

import 'package:restaurant/core/utils/token_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthEndpoint(options.path)) {
      handler.next(options);
      return;
    }
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  bool _isAuthEndpoint(String path) =>
      path.contains('/auth/login') || path.contains('/auth/register');

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      TokenStorage.clear();
    }
    handler.next(err);
  }
}
