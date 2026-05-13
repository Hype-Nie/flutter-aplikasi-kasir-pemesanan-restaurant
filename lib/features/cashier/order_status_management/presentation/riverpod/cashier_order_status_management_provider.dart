import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CashierOrderStatusManagementStatus { initial, loading, success, failure }

class CashierOrderStatusManagementState extends Equatable {
  const CashierOrderStatusManagementState({
    this.status = CashierOrderStatusManagementStatus.initial,
    this.message = '',
  });

  final CashierOrderStatusManagementStatus status;
  final String message;

  CashierOrderStatusManagementState copyWith({
    CashierOrderStatusManagementStatus? status,
    String? message,
  }) {
    return CashierOrderStatusManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CashierOrderStatusManagementNotifier
    extends Notifier<CashierOrderStatusManagementState> {
  @override
  CashierOrderStatusManagementState build() =>
      const CashierOrderStatusManagementState();

  void started() {
    state = state.copyWith(status: CashierOrderStatusManagementStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierOrderStatusManagementStatus.success);
  }
}

final cashierOrderStatusManagementProvider =
    NotifierProvider<
      CashierOrderStatusManagementNotifier,
      CashierOrderStatusManagementState
    >(CashierOrderStatusManagementNotifier.new);
