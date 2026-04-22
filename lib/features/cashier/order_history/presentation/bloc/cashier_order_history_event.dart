import 'package:equatable/equatable.dart';

abstract class CashierOrderHistoryEvent extends Equatable {
  const CashierOrderHistoryEvent();

  @override
  List<Object?> get props => [];
}

class CashierOrderHistoryStarted extends CashierOrderHistoryEvent {
  const CashierOrderHistoryStarted();
}
