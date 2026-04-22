import 'package:equatable/equatable.dart';

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
