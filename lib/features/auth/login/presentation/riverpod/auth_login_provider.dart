import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/config/strings/auth_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/fcm_service.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/auth/domain/entities/user.dart';

enum AuthLoginStatus { initial, loading, success, failure }

class AuthLoginState extends Equatable {
  final AuthLoginStatus status;
  final String message;
  final User? user;

  const AuthLoginState({
    this.status = AuthLoginStatus.initial,
    this.message = '',
    this.user,
  });

  AuthLoginState copyWith({
    AuthLoginStatus? status,
    String? message,
    User? user,
  }) => AuthLoginState(
    status: status ?? this.status,
    message: message ?? this.message,
    user: user ?? this.user,
  );

  @override
  List<Object?> get props => [status, message, user];
}

class AuthLoginNotifier extends Notifier<AuthLoginState> {
  @override
  AuthLoginState build() => const AuthLoginState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthLoginStatus.loading, message: '');
    var hasDeviceToken = false;

    try {
      final deviceToken = await FcmService.getToken();
      final appVersion = await FcmService.getAppVersion();
      final deviceType = FcmService.deviceType;

      final payload = <String, dynamic>{
        'email': email,
        'password': password,
        'device_type': deviceType,
        'app_version': appVersion,
      };
      if (deviceToken != null && deviceToken.isNotEmpty) {
        payload['device_token'] = deviceToken;
        hasDeviceToken = true;
        debugPrint(
          '[AuthLogin] device_token attached: ${_maskToken(deviceToken)}',
        );
      } else {
        debugPrint('[AuthLogin] device_token missing/empty, skipped');
      }
      debugPrint(
        '[AuthLogin] sending login request | has_device_token=${payload.containsKey('device_token')}',
      );

      final response = await DioClient.instance.post(
        '/api/auth/login',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: payload,
      );
      debugPrint(
        '[AuthLogin] login response received | status=${response.statusCode} | has_device_token=${payload.containsKey('device_token')}',
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      await TokenStorage.saveToken(token);
      await TokenStorage.saveRole(user.role);
      await TokenStorage.saveUserId(user.id);
      await TokenStorage.saveName(user.name);

      state = state.copyWith(
        status: AuthLoginStatus.success,
        message: AuthStrings.loginSuccess,
        user: user,
      );
    } on DioException catch (e) {
      debugPrint(
        '[AuthLogin] login failed | status=${e.response?.statusCode} | has_device_token=$hasDeviceToken',
      );
      final msg = _mapError(e);
      state = state.copyWith(status: AuthLoginStatus.failure, message: msg);
    } catch (_) {
      state = state.copyWith(
        status: AuthLoginStatus.failure,
        message: AuthStrings.unexpectedError,
      );
    }
  }

  void reset() => state = const AuthLoginState();

  String _maskToken(String token) {
    if (token.length <= 10) return token;
    return '${token.substring(0, 8)}...${token.substring(token.length - 6)}';
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthStrings.networkError;
    }
    final data = e.response?.data;
    if (data is Map) {
      if (e.response?.statusCode == 422) {
        final errors = data['errors'];
        if (errors is Map) {
          final first = errors.values.first;
          return first is List ? first.first.toString() : first.toString();
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    if (e.response?.statusCode == 401) return AuthStrings.invalidCredentials;
    return AuthStrings.unexpectedError;
  }
}

final authLoginProvider = NotifierProvider<AuthLoginNotifier, AuthLoginState>(
  AuthLoginNotifier.new,
);
final authLoginProvider = NotifierProvider<AuthLoginNotifier, AuthLoginState>(
  AuthLoginNotifier.new,
);
