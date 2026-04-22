import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_change_password_event.dart';
import 'customer_change_password_state.dart';

class CustomerChangePasswordBloc extends Bloc<CustomerChangePasswordEvent, CustomerChangePasswordState> {
  CustomerChangePasswordBloc() : super(const CustomerChangePasswordState()) {
    on<CustomerChangePasswordStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerChangePasswordStarted event,
    Emitter<CustomerChangePasswordState> emit,
  ) async {
    emit(state.copyWith(status: CustomerChangePasswordStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerChangePasswordStatus.success));
  }
}
