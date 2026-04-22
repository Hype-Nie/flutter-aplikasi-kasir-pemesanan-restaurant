import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_checkout_event.dart';
import 'customer_checkout_state.dart';

class CustomerCheckoutBloc extends Bloc<CustomerCheckoutEvent, CustomerCheckoutState> {
  CustomerCheckoutBloc() : super(const CustomerCheckoutState()) {
    on<CustomerCheckoutStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerCheckoutStarted event,
    Emitter<CustomerCheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CustomerCheckoutStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerCheckoutStatus.success));
  }
}
