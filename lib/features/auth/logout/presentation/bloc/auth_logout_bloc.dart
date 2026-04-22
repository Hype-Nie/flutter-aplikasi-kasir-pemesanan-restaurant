import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_logout_event.dart';
import 'auth_logout_state.dart';

class AuthLogoutBloc extends Bloc<AuthLogoutEvent, AuthLogoutState> {
  AuthLogoutBloc() : super(const AuthLogoutState()) {
    on<AuthLogoutStarted>(_onStarted);
  }

  Future<void> _onStarted(
    AuthLogoutStarted event,
    Emitter<AuthLogoutState> emit,
  ) async {
    emit(state.copyWith(status: AuthLogoutStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: AuthLogoutStatus.success));
  }
}
