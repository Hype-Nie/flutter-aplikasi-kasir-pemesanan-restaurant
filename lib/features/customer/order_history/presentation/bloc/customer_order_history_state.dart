import 'package:equatable/equatable.dart';

enum CustomerOrderHistoryStatus { initial, loading, success, failure }

class CustomerOrderHistoryState extends Equatable {
  const CustomerOrderHistoryState({
    this.status = CustomerOrderHistoryStatus.initial,
    this.message = '',
  });

  final CustomerOrderHistoryStatus status;
  final String message;

  CustomerOrderHistoryState copyWith({
    CustomerOrderHistoryStatus? status,
    String? message,
  }) {
    return CustomerOrderHistoryState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
