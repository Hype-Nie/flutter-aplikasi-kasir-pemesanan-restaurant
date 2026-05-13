import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerCheckoutProvider =
    StateNotifierProvider<CustomerCheckoutNotifier, CustomerCheckoutState>(
      (ref) => CustomerCheckoutNotifier(),
    );

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

class CustomerCheckoutNotifier extends StateNotifier<CustomerCheckoutState> {
  CustomerCheckoutNotifier() : super(const CustomerCheckoutState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerCheckoutStatus.loading);
    state = state.copyWith(status: CustomerCheckoutStatus.success);
  }
}
