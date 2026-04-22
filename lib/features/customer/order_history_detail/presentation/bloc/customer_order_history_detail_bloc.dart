import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_order_history_detail_event.dart';
import 'customer_order_history_detail_state.dart';

class CustomerOrderHistoryDetailBloc extends Bloc<CustomerOrderHistoryDetailEvent, CustomerOrderHistoryDetailState> {
  CustomerOrderHistoryDetailBloc() : super(const CustomerOrderHistoryDetailState()) {
    on<CustomerOrderHistoryDetailStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerOrderHistoryDetailStarted event,
    Emitter<CustomerOrderHistoryDetailState> emit,
  ) async {
    emit(state.copyWith(status: CustomerOrderHistoryDetailStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerOrderHistoryDetailStatus.success));
  }
}
