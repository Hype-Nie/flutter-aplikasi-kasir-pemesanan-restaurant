import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_order_history_event.dart';
import 'customer_order_history_state.dart';

class CustomerOrderHistoryBloc extends Bloc<CustomerOrderHistoryEvent, CustomerOrderHistoryState> {
  CustomerOrderHistoryBloc() : super(const CustomerOrderHistoryState()) {
    on<CustomerOrderHistoryStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerOrderHistoryStarted event,
    Emitter<CustomerOrderHistoryState> emit,
  ) async {
    emit(state.copyWith(status: CustomerOrderHistoryStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerOrderHistoryStatus.success));
  }
}
