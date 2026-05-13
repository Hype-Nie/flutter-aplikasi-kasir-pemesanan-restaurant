import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CashierCategoryManagementStatus { initial, loading, success, failure }

class CashierCategoryManagementState extends Equatable {
  const CashierCategoryManagementState({
    this.status = CashierCategoryManagementStatus.initial,
    this.message = '',
  });

  final CashierCategoryManagementStatus status;
  final String message;

  CashierCategoryManagementState copyWith({
    CashierCategoryManagementStatus? status,
    String? message,
  }) {
    return CashierCategoryManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

class CashierCategoryManagementNotifier
    extends Notifier<CashierCategoryManagementState> {
  @override
  CashierCategoryManagementState build() =>
      const CashierCategoryManagementState();

  void started() {
    state = state.copyWith(status: CashierCategoryManagementStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierCategoryManagementStatus.success);
  }
}

final cashierCategoryManagementProvider =
    NotifierProvider<
      CashierCategoryManagementNotifier,
      CashierCategoryManagementState
    >(CashierCategoryManagementNotifier.new);
