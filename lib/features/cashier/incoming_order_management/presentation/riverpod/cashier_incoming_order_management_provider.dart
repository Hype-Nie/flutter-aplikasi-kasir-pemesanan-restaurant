import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CashierIncomingOrderManagementStatus { initial, loading, success, failure }

class CashierIncomingOrderManagementState extends Equatable {
  const CashierIncomingOrderManagementState({
    this.status = CashierIncomingOrderManagementStatus.initial,
    this.message = '',
  });

  final CashierIncomingOrderManagementStatus status;
  final String message;

  CashierIncomingOrderManagementState copyWith({
    CashierIncomingOrderManagementStatus? status,
    String? message,
  }) {
    return CashierIncomingOrderManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CashierIncomingOrderManagementNotifier
    extends Notifier<CashierIncomingOrderManagementState> {
  @override
  CashierIncomingOrderManagementState build() =>
      const CashierIncomingOrderManagementState();

  void started() {
    state = state.copyWith(
      status: CashierIncomingOrderManagementStatus.loading,
    );

    // TODO: Implement feature logic.
    state = state.copyWith(
      status: CashierIncomingOrderManagementStatus.success,
    );
  }
}

final cashierIncomingOrderManagementProvider =
    NotifierProvider<
      CashierIncomingOrderManagementNotifier,
      CashierIncomingOrderManagementState
    >(CashierIncomingOrderManagementNotifier.new);
