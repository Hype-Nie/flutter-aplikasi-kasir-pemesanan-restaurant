import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerProfileProvider =
    StateNotifierProvider<CustomerProfileNotifier, CustomerProfileState>(
      (ref) => CustomerProfileNotifier(),
    );

enum CustomerProfileStatus { initial, loading, success, failure }

class CustomerProfileState extends Equatable {
  const CustomerProfileState({
    this.status = CustomerProfileStatus.initial,
    this.message = '',
  });

  final CustomerProfileStatus status;
  final String message;

  CustomerProfileState copyWith({
    CustomerProfileStatus? status,
    String? message,
  }) {
    return CustomerProfileState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CustomerProfileNotifier extends StateNotifier<CustomerProfileState> {
  CustomerProfileNotifier() : super(const CustomerProfileState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerProfileStatus.loading);
    state = state.copyWith(status: CustomerProfileStatus.success);
  }
}
