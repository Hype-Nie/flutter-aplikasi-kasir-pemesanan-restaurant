import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class CashierOrderHistoryNotifier extends Notifier<CashierOrderHistoryState> {
  @override
  CashierOrderHistoryState build() => const CashierOrderHistoryState();

  void started() {
    state = state.copyWith(status: CashierOrderHistoryStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierOrderHistoryStatus.success);
  }
}

final cashierOrderHistoryProvider =
    NotifierProvider<CashierOrderHistoryNotifier, CashierOrderHistoryState>(
      CashierOrderHistoryNotifier.new,
    );
