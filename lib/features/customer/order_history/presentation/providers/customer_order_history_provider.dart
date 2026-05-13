import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerOrderHistoryProvider =
    StateNotifierProvider<
      CustomerOrderHistoryNotifier,
      CustomerOrderHistoryState
    >((ref) => CustomerOrderHistoryNotifier());

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

class CustomerOrderHistoryNotifier
    extends StateNotifier<CustomerOrderHistoryState> {
  CustomerOrderHistoryNotifier() : super(const CustomerOrderHistoryState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerOrderHistoryStatus.loading);
    state = state.copyWith(status: CustomerOrderHistoryStatus.success);
  }
}
