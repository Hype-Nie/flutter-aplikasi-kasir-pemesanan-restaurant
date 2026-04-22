import 'package:equatable/equatable.dart';

enum AuthLogoutStatus { initial, loading, success, failure }

class AuthLogoutState extends Equatable {
  const AuthLogoutState({
    this.status = AuthLogoutStatus.initial,
    this.message = '',
  });

  final AuthLogoutStatus status;
  final String message;

  AuthLogoutState copyWith({
    AuthLogoutStatus? status,
    String? message,
  }) {
    return AuthLogoutState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
