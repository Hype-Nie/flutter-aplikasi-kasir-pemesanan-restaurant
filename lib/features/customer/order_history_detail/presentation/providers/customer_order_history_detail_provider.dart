import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerOrderHistoryDetailProvider =
    StateNotifierProvider<
      CustomerOrderHistoryDetailNotifier,
      CustomerOrderHistoryDetailState
    >((ref) => CustomerOrderHistoryDetailNotifier());

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

class CustomerOrderHistoryDetailNotifier
    extends StateNotifier<CustomerOrderHistoryDetailState> {
  CustomerOrderHistoryDetailNotifier()
    : super(const CustomerOrderHistoryDetailState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerOrderHistoryDetailStatus.loading);
    state = state.copyWith(status: CustomerOrderHistoryDetailStatus.success);
  }
}
