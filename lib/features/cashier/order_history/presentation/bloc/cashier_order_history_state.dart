import 'package:equatable/equatable.dart';

enum CashierOrderHistoryStatus { initial, loading, success, failure }

class CashierOrderHistoryState extends Equatable {
  const CashierOrderHistoryState({
    this.status = CashierOrderHistoryStatus.initial,
    this.message = '',
  });

  final CashierOrderHistoryStatus status;
  final String message;

  CashierOrderHistoryState copyWith({
    CashierOrderHistoryStatus? status,
    String? message,
  }) {
    return CashierOrderHistoryState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
