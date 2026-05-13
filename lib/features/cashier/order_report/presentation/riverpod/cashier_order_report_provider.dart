import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class CashierOrderReportNotifier extends Notifier<CashierOrderReportState> {
  @override
  CashierOrderReportState build() => const CashierOrderReportState();

  void started() {
    state = state.copyWith(status: CashierOrderReportStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierOrderReportStatus.success);
  }
}

final cashierOrderReportProvider =
    NotifierProvider<CashierOrderReportNotifier, CashierOrderReportState>(
      CashierOrderReportNotifier.new,
    );
