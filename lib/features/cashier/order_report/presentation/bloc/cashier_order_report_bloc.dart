import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_order_report_event.dart';
import 'cashier_order_report_state.dart';

class CashierOrderReportBloc extends Bloc<CashierOrderReportEvent, CashierOrderReportState> {
  CashierOrderReportBloc() : super(const CashierOrderReportState()) {
    on<CashierOrderReportStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierOrderReportStarted event,
    Emitter<CashierOrderReportState> emit,
  ) async {
    emit(state.copyWith(status: CashierOrderReportStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierOrderReportStatus.success));
  }
}
