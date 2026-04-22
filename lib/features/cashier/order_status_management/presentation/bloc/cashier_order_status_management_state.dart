import 'package:equatable/equatable.dart';

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
