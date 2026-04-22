import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_dashboard_event.dart';
import 'customer_dashboard_state.dart';

class CustomerDashboardBloc extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  CustomerDashboardBloc() : super(const CustomerDashboardState()) {
    on<CustomerDashboardStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerDashboardStarted event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    emit(state.copyWith(status: CustomerDashboardStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerDashboardStatus.success));
  }
}
