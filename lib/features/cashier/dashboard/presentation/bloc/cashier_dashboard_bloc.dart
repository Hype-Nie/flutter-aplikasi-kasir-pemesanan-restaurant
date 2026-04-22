import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_dashboard_event.dart';
import 'cashier_dashboard_state.dart';

class CashierDashboardBloc extends Bloc<CashierDashboardEvent, CashierDashboardState> {
  CashierDashboardBloc() : super(const CashierDashboardState()) {
    on<CashierDashboardStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierDashboardStarted event,
    Emitter<CashierDashboardState> emit,
  ) async {
    emit(state.copyWith(status: CashierDashboardStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierDashboardStatus.success));
  }
}
