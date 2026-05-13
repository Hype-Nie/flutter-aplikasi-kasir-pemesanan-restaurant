import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerDashboardProvider =
    StateNotifierProvider<CustomerDashboardNotifier, CustomerDashboardState>(
      (ref) => CustomerDashboardNotifier(),
    );

enum CustomerDashboardStatus { initial, loading, success, failure }

class CustomerDashboardState extends Equatable {
  const CustomerDashboardState({
    this.status = CustomerDashboardStatus.initial,
    this.message = '',
  });

  final CustomerDashboardStatus status;
  final String message;

  CustomerDashboardState copyWith({
    CustomerDashboardStatus? status,
    String? message,
  }) {
    return CustomerDashboardState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CustomerDashboardNotifier extends StateNotifier<CustomerDashboardState> {
  CustomerDashboardNotifier() : super(const CustomerDashboardState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerDashboardStatus.loading);
    state = state.copyWith(status: CustomerDashboardStatus.success);
  }
}
