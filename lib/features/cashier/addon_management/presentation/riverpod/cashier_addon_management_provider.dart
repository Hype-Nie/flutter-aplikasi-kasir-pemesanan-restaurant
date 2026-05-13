import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CashierAddonManagementStatus { initial, loading, success, failure }

class CashierAddonManagementState extends Equatable {
  const CashierAddonManagementState({
    this.status = CashierAddonManagementStatus.initial,
    this.message = '',
  });

  final CashierAddonManagementStatus status;
  final String message;

  CashierAddonManagementState copyWith({
    CashierAddonManagementStatus? status,
    String? message,
  }) {
    return CashierAddonManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CashierAddonManagementNotifier
    extends Notifier<CashierAddonManagementState> {
  @override
  CashierAddonManagementState build() => const CashierAddonManagementState();

  void started() {
    state = state.copyWith(status: CashierAddonManagementStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierAddonManagementStatus.success);
  }
}

final cashierAddonManagementProvider =
    NotifierProvider<
      CashierAddonManagementNotifier,
      CashierAddonManagementState
    >(CashierAddonManagementNotifier.new);
