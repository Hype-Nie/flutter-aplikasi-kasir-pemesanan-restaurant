import 'package:equatable/equatable.dart';

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
