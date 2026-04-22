import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_incoming_order_management_event.dart';
import 'cashier_incoming_order_management_state.dart';

class CashierIncomingOrderManagementBloc extends Bloc<CashierIncomingOrderManagementEvent, CashierIncomingOrderManagementState> {
  CashierIncomingOrderManagementBloc() : super(const CashierIncomingOrderManagementState()) {
    on<CashierIncomingOrderManagementStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierIncomingOrderManagementStarted event,
    Emitter<CashierIncomingOrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: CashierIncomingOrderManagementStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierIncomingOrderManagementStatus.success));
  }
}
