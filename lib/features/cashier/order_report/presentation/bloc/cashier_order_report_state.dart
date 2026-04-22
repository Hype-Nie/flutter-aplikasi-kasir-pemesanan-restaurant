import 'package:equatable/equatable.dart';

enum CashierOrderReportStatus { initial, loading, success, failure }

class CashierOrderReportState extends Equatable {
  const CashierOrderReportState({
    this.status = CashierOrderReportStatus.initial,
    this.message = '',
  });

  final CashierOrderReportStatus status;
  final String message;

  CashierOrderReportState copyWith({
    CashierOrderReportStatus? status,
    String? message,
  }) {
    return CashierOrderReportState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
