import 'package:equatable/equatable.dart';

enum CustomerCartStatus { initial, loading, success, failure }

class CustomerCartState extends Equatable {
  const CustomerCartState({
    this.status = CustomerCartStatus.initial,
    this.message = '',
  });

  final CustomerCartStatus status;
  final String message;

  CustomerCartState copyWith({
    CustomerCartStatus? status,
    String? message,
  }) {
    return CustomerCartState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
