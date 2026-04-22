import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_profile_event.dart';
import 'customer_profile_state.dart';

class CustomerProfileBloc extends Bloc<CustomerProfileEvent, CustomerProfileState> {
  CustomerProfileBloc() : super(const CustomerProfileState()) {
    on<CustomerProfileStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerProfileStarted event,
    Emitter<CustomerProfileState> emit,
  ) async {
    emit(state.copyWith(status: CustomerProfileStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerProfileStatus.success));
  }
}
