import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerChangePasswordProvider =
    StateNotifierProvider<
      CustomerChangePasswordNotifier,
      CustomerChangePasswordState
    >((ref) => CustomerChangePasswordNotifier());

enum CustomerChangePasswordStatus { initial, loading, success, failure }

class CustomerChangePasswordState extends Equatable {
  const CustomerChangePasswordState({
    this.status = CustomerChangePasswordStatus.initial,
    this.message = '',
  });

  final CustomerChangePasswordStatus status;
  final String message;

  CustomerChangePasswordState copyWith({
    CustomerChangePasswordStatus? status,
    String? message,
  }) {
    return CustomerChangePasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CustomerChangePasswordNotifier
    extends StateNotifier<CustomerChangePasswordState> {
  CustomerChangePasswordNotifier()
    : super(const CustomerChangePasswordState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerChangePasswordStatus.loading);
    state = state.copyWith(status: CustomerChangePasswordStatus.success);
  }
}
