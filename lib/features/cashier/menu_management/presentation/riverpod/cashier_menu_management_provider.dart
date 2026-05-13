import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CashierMenuManagementStatus { initial, loading, success, failure }

class CashierMenuManagementState extends Equatable {
  const CashierMenuManagementState({
    this.status = CashierMenuManagementStatus.initial,
    this.message = '',
  });

  final CashierMenuManagementStatus status;
  final String message;

  CashierMenuManagementState copyWith({
    CashierMenuManagementStatus? status,
    String? message,
  }) {
    return CashierMenuManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CashierMenuManagementNotifier
    extends Notifier<CashierMenuManagementState> {
  @override
  CashierMenuManagementState build() => const CashierMenuManagementState();

  void started() {
    state = state.copyWith(status: CashierMenuManagementStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierMenuManagementStatus.success);
  }
}

final cashierMenuManagementProvider =
    NotifierProvider<CashierMenuManagementNotifier, CashierMenuManagementState>(
      CashierMenuManagementNotifier.new,
    );
