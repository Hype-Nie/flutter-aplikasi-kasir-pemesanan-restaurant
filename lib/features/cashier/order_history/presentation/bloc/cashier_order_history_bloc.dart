import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_order_history_event.dart';
import 'cashier_order_history_state.dart';

class CashierOrderHistoryBloc extends Bloc<CashierOrderHistoryEvent, CashierOrderHistoryState> {
  CashierOrderHistoryBloc() : super(const CashierOrderHistoryState()) {
    on<CashierOrderHistoryStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierOrderHistoryStarted event,
    Emitter<CashierOrderHistoryState> emit,
  ) async {
    emit(state.copyWith(status: CashierOrderHistoryStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierOrderHistoryStatus.success));
  }
}
