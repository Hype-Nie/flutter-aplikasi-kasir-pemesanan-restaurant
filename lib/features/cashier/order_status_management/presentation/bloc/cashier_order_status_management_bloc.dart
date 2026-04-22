import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_order_status_management_event.dart';
import 'cashier_order_status_management_state.dart';

class CashierOrderStatusManagementBloc extends Bloc<CashierOrderStatusManagementEvent, CashierOrderStatusManagementState> {
  CashierOrderStatusManagementBloc() : super(const CashierOrderStatusManagementState()) {
    on<CashierOrderStatusManagementStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierOrderStatusManagementStarted event,
    Emitter<CashierOrderStatusManagementState> emit,
  ) async {
    emit(state.copyWith(status: CashierOrderStatusManagementStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierOrderStatusManagementStatus.success));
  }
}
