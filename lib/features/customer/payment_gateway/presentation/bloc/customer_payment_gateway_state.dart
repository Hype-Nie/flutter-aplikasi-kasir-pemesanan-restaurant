import 'package:equatable/equatable.dart';

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
