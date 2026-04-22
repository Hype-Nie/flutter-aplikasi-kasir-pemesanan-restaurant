import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_addon_management_event.dart';
import 'cashier_addon_management_state.dart';

class CashierAddonManagementBloc extends Bloc<CashierAddonManagementEvent, CashierAddonManagementState> {
  CashierAddonManagementBloc() : super(const CashierAddonManagementState()) {
    on<CashierAddonManagementStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierAddonManagementStarted event,
    Emitter<CashierAddonManagementState> emit,
  ) async {
    emit(state.copyWith(status: CashierAddonManagementStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierAddonManagementStatus.success));
  }
}
