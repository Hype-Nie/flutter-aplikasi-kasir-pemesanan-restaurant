import 'package:equatable/equatable.dart';

enum CustomerOrderHistoryDetailStatus { initial, loading, success, failure }

class CustomerOrderHistoryDetailState extends Equatable {
  const CustomerOrderHistoryDetailState({
    this.status = CustomerOrderHistoryDetailStatus.initial,
    this.message = '',
  });

  final CustomerOrderHistoryDetailStatus status;
  final String message;

  CustomerOrderHistoryDetailState copyWith({
    CustomerOrderHistoryDetailStatus? status,
    String? message,
  }) {
    return CustomerOrderHistoryDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
