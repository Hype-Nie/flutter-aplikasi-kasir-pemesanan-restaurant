import 'package:equatable/equatable.dart';

enum CashierDashboardStatus { initial, loading, success, failure }

class CashierDashboardState extends Equatable {
  const CashierDashboardState({
    this.status = CashierDashboardStatus.initial,
    this.message = '',
  });

  final CashierDashboardStatus status;
  final String message;

  CashierDashboardState copyWith({
    CashierDashboardStatus? status,
    String? message,
  }) {
    return CashierDashboardState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
