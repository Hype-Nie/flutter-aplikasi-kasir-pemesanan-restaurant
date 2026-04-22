import 'package:equatable/equatable.dart';

enum AuthLoginStatus { initial, loading, success, failure }

class AuthLoginState extends Equatable {
  const AuthLoginState({
    this.status = AuthLoginStatus.initial,
    this.message = '',
  });

  final AuthLoginStatus status;
  final String message;

  AuthLoginState copyWith({
    AuthLoginStatus? status,
    String? message,
  }) {
    return AuthLoginState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
