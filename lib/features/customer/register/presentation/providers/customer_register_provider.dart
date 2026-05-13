import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerRegisterProvider =
    StateNotifierProvider<CustomerRegisterNotifier, CustomerRegisterState>(
      (ref) => CustomerRegisterNotifier(),
    );

enum CustomerRegisterStatus { initial, loading, success, failure }

class CustomerRegisterState extends Equatable {
  const CustomerRegisterState({
    this.status = CustomerRegisterStatus.initial,
    this.message = '',
  });

  final CustomerRegisterStatus status;
  final String message;

  CustomerRegisterState copyWith({
    CustomerRegisterStatus? status,
    String? message,
  }) {
    return CustomerRegisterState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CustomerRegisterNotifier extends StateNotifier<CustomerRegisterState> {
  CustomerRegisterNotifier() : super(const CustomerRegisterState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerRegisterStatus.loading);
    state = state.copyWith(status: CustomerRegisterStatus.success);
  }
}
