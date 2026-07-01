import 'package:dio/dio.dart';
import '../utils/connectivity_helper.dart';

class ConnectivityInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final hasConnection = await ConnectivityHelper.hasInternetConnection();
    if (!hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
      );
    }
    handler.next(options);
  }
}
