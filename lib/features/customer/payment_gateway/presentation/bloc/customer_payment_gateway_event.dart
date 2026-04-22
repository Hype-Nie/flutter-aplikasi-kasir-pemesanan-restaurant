import 'package:equatable/equatable.dart';

abstract class CustomerPaymentGatewayEvent extends Equatable {
  const CustomerPaymentGatewayEvent();

  @override
  List<Object?> get props => [];
}

class CustomerPaymentGatewayStarted extends CustomerPaymentGatewayEvent {
  const CustomerPaymentGatewayStarted();
}
