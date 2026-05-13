import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthLogoutStatus { initial, loading, success, failure }

class AuthLogoutState extends Equatable {
  const AuthLogoutState({
    this.status = AuthLogoutStatus.initial,
    this.message = '',
  });

  final AuthLogoutStatus status;
  final String message;

  AuthLogoutState copyWith({AuthLogoutStatus? status, String? message}) {
    return AuthLogoutState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class AuthLogoutNotifier extends Notifier<AuthLogoutState> {
  @override
  AuthLogoutState build() => const AuthLogoutState();

  void started() {
    state = state.copyWith(status: AuthLogoutStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: AuthLogoutStatus.success);
  }
}

final authLogoutProvider =
    NotifierProvider<AuthLogoutNotifier, AuthLogoutState>(
      AuthLogoutNotifier.new,
    );
