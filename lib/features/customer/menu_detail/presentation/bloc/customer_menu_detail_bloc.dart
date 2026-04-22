import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_menu_detail_event.dart';
import 'customer_menu_detail_state.dart';

class CustomerMenuDetailBloc extends Bloc<CustomerMenuDetailEvent, CustomerMenuDetailState> {
  CustomerMenuDetailBloc() : super(const CustomerMenuDetailState()) {
    on<CustomerMenuDetailStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerMenuDetailStarted event,
    Emitter<CustomerMenuDetailState> emit,
  ) async {
    emit(state.copyWith(status: CustomerMenuDetailStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerMenuDetailStatus.success));
  }
}
