import 'package:equatable/equatable.dart';

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
