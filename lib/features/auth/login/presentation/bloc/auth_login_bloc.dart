import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_login_event.dart';
import 'auth_login_state.dart';

class AuthLoginBloc extends Bloc<AuthLoginEvent, AuthLoginState> {
  AuthLoginBloc() : super(const AuthLoginState()) {
    on<AuthLoginStarted>(_onStarted);
  }

  Future<void> _onStarted(
    AuthLoginStarted event,
    Emitter<AuthLoginState> emit,
  ) async {
    emit(state.copyWith(status: AuthLoginStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: AuthLoginStatus.success));
  }
}
