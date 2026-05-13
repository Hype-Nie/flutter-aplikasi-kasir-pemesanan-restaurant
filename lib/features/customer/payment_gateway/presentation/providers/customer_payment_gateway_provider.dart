import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerPaymentGatewayProvider =
    StateNotifierProvider<
      CustomerPaymentGatewayNotifier,
      CustomerPaymentGatewayState
    >((ref) => CustomerPaymentGatewayNotifier());

enum CustomerPaymentGatewayStatus { initial, loading, success, failure }

class CustomerPaymentGatewayState extends Equatable {
  const CustomerPaymentGatewayState({
    this.status = CustomerPaymentGatewayStatus.initial,
    this.message = '',
  });

  final CustomerPaymentGatewayStatus status;
  final String message;

  CustomerPaymentGatewayState copyWith({
    CustomerPaymentGatewayStatus? status,
    String? message,
  }) {
    return CustomerPaymentGatewayState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CustomerPaymentGatewayNotifier
    extends StateNotifier<CustomerPaymentGatewayState> {
  CustomerPaymentGatewayNotifier()
    : super(const CustomerPaymentGatewayState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerPaymentGatewayStatus.loading);
    state = state.copyWith(status: CustomerPaymentGatewayStatus.success);
  }
}
