import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthLoginStatus { initial, loading, success, failure }

class AuthLoginState extends Equatable {
  const AuthLoginState({
    this.status = AuthLoginStatus.initial,
    this.message = '',
  });

  final AuthLoginStatus status;
  final String message;

  AuthLoginState copyWith({AuthLoginStatus? status, String? message}) {
    return AuthLoginState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class AuthLoginNotifier extends Notifier<AuthLoginState> {
  @override
  AuthLoginState build() => const AuthLoginState();

  void started() {
    state = state.copyWith(status: AuthLoginStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: AuthLoginStatus.success);
  }
}

final authLoginProvider = NotifierProvider<AuthLoginNotifier, AuthLoginState>(
  AuthLoginNotifier.new,
);
