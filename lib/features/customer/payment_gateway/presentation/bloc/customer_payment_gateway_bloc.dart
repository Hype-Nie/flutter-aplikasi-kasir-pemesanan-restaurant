import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_payment_gateway_event.dart';
import 'customer_payment_gateway_state.dart';

class CustomerPaymentGatewayBloc extends Bloc<CustomerPaymentGatewayEvent, CustomerPaymentGatewayState> {
  CustomerPaymentGatewayBloc() : super(const CustomerPaymentGatewayState()) {
    on<CustomerPaymentGatewayStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CustomerPaymentGatewayStarted event,
    Emitter<CustomerPaymentGatewayState> emit,
  ) async {
    emit(state.copyWith(status: CustomerPaymentGatewayStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CustomerPaymentGatewayStatus.success));
  }
}
