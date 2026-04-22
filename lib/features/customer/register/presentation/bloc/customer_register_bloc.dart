import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_register_event.dart';
import 'customer_register_state.dart';

class CustomerRegisterBloc extends Bloc<CustomerRegisterEvent, CustomerRegisterState> {
  CustomerRegisterBloc() : super(const CustomerRegisterState()) {
    on<CustomerRegisterStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerRegisterStarted event,
    Emitter<CustomerRegisterState> emit,
  ) async {
    emit(state.copyWith(status: CustomerRegisterStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerRegisterStatus.success));
  }
}
