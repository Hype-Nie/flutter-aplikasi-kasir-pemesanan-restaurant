import 'package:equatable/equatable.dart';

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
