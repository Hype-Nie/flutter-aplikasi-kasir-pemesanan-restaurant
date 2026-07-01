import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';

enum AuthLogoutStatus { initial, loading, success, failure }

class AuthLogoutState extends Equatable {
  final AuthLogoutStatus status;
  final String message;

  const AuthLogoutState({
    this.status = AuthLogoutStatus.initial,
    this.message = '',
  });

  AuthLogoutState copyWith({AuthLogoutStatus? status, String? message}) =>
      AuthLogoutState(
        status: status ?? this.status,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => [status, message];
}

class AuthLogoutNotifier extends Notifier<AuthLogoutState> {
  @override
  AuthLogoutState build() => const AuthLogoutState();

  Future<void> logout() async {
    state = state.copyWith(status: AuthLogoutStatus.loading, message: '');

    try {
      await DioClient.instance.post('/api/auth/logout');
      await TokenStorage.clear();

      state = state.copyWith(status: AuthLogoutStatus.success);
    } on DioException catch (e) {
      await TokenStorage.clear();
      final msg = _mapError(e);
      state = state.copyWith(status: AuthLogoutStatus.failure, message: msg);
    } catch (_) {
      await TokenStorage.clear();
      state = state.copyWith(
        status: AuthLogoutStatus.failure,
        message: 'Logout failed. Try again.',
      );
    }
  }

  void reset() => state = const AuthLogoutState();

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Network error. Check your connection.';
  }
}

final authLogoutProvider =
    NotifierProvider<AuthLogoutNotifier, AuthLogoutState>(
      AuthLogoutNotifier.new,
    );
