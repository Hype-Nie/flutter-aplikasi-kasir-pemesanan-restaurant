import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerMenuDetailProvider =
    StateNotifierProvider<CustomerMenuDetailNotifier, CustomerMenuDetailState>(
      (ref) => CustomerMenuDetailNotifier(),
    );

enum CustomerMenuDetailStatus { initial, loading, success, failure }

class CustomerMenuDetailState extends Equatable {
  const CustomerMenuDetailState({
    this.status = CustomerMenuDetailStatus.initial,
    this.message = '',
  });

  final CustomerMenuDetailStatus status;
  final String message;

  CustomerMenuDetailState copyWith({
    CustomerMenuDetailStatus? status,
    String? message,
  }) {
    return CustomerMenuDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CustomerMenuDetailNotifier
    extends StateNotifier<CustomerMenuDetailState> {
  CustomerMenuDetailNotifier() : super(const CustomerMenuDetailState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerMenuDetailStatus.loading);
    state = state.copyWith(status: CustomerMenuDetailStatus.success);
  }
}
