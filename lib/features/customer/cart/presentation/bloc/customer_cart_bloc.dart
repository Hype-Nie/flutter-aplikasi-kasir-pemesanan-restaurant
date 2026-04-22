import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_cart_event.dart';
import 'customer_cart_state.dart';

class CustomerCartBloc extends Bloc<CustomerCartEvent, CustomerCartState> {
  CustomerCartBloc() : super(const CustomerCartState()) {
    on<CustomerCartStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerCartStarted event,
    Emitter<CustomerCartState> emit,
  ) async {
    emit(state.copyWith(status: CustomerCartStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerCartStatus.success));
  }
}
