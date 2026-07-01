import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/config/strings/auth_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/auth/domain/entities/user.dart';

enum AuthRegisterStatus { initial, loading, success, failure }

class AuthRegisterState extends Equatable {
  final AuthRegisterStatus status;
  final String message;

  const AuthRegisterState({
    this.status = AuthRegisterStatus.initial,
    this.message = '',
  });

  AuthRegisterState copyWith({AuthRegisterStatus? status, String? message}) =>
      AuthRegisterState(
        status: status ?? this.status,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => [status, message];
}

class AuthRegisterNotifier extends Notifier<AuthRegisterState> {
  @override
  AuthRegisterState build() => const AuthRegisterState();

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) {
      state = state.copyWith(
        status: AuthRegisterStatus.failure,
        message: AuthStrings.passwordMismatch,
      );
      return;
    }

    state = state.copyWith(status: AuthRegisterStatus.loading, message: '');

    try {
      final response = await DioClient.instance.post(
        '/api/auth/register',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_token': 'fcm_token_here',
          'device_type': 'android',
          'app_version': '1.0.0',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await TokenStorage.saveToken(token);
      await TokenStorage.saveRole('customer');
      await TokenStorage.saveUserId(user.id);

      state = state.copyWith(
        status: AuthRegisterStatus.success,
        message: AuthStrings.registerSuccess,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthRegisterStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthRegisterStatus.failure,
        message: AuthStrings.unexpectedError,
      );
    }
  }

  void reset() => state = const AuthRegisterState();

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthStrings.networkError;
    }
    if (e.response?.statusCode == 422) {
      final errors = e.response?.data?['errors'];
      if (errors is Map) {
        final first = errors.values.first;
        return first is List ? first.first.toString() : first.toString();
      }
    }
    return AuthStrings.unexpectedError;
  }
}

final authRegisterProvider =
    NotifierProvider<AuthRegisterNotifier, AuthRegisterState>(
      AuthRegisterNotifier.new,
    );
