import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_menu_management_event.dart';
import 'cashier_menu_management_state.dart';

class CashierMenuManagementBloc extends Bloc<CashierMenuManagementEvent, CashierMenuManagementState> {
  CashierMenuManagementBloc() : super(const CashierMenuManagementState()) {
    on<CashierMenuManagementStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierMenuManagementStarted event,
    Emitter<CashierMenuManagementState> emit,
  ) async {
    emit(state.copyWith(status: CashierMenuManagementStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierMenuManagementStatus.success));
  }
}
