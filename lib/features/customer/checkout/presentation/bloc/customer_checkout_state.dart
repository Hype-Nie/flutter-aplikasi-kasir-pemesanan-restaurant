import 'package:equatable/equatable.dart';

enum CustomerCheckoutStatus { initial, loading, success, failure }

class CustomerCheckoutState extends Equatable {
  const CustomerCheckoutState({
    this.status = CustomerCheckoutStatus.initial,
    this.message = '',
  });

  final CustomerCheckoutStatus status;
  final String message;

  CustomerCheckoutState copyWith({
    CustomerCheckoutStatus? status,
    String? message,
  }) {
    return CustomerCheckoutState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
