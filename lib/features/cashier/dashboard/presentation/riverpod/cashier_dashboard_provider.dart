import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class CashierDashboardNotifier extends Notifier<CashierDashboardState> {
  @override
  CashierDashboardState build() => const CashierDashboardState();

  void started() {
    state = state.copyWith(status: CashierDashboardStatus.loading);

    // TODO: Implement feature logic.
    state = state.copyWith(status: CashierDashboardStatus.success);
  }
}

final cashierDashboardProvider =
    NotifierProvider<CashierDashboardNotifier, CashierDashboardState>(
      CashierDashboardNotifier.new,
    );
