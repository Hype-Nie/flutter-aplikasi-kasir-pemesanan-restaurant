import 'package:equatable/equatable.dart';

abstract class CashierOrderStatusManagementEvent extends Equatable {
  const CashierOrderStatusManagementEvent();

  @override
  List<Object?> get props => [];
}

class CashierOrderStatusManagementStarted extends CashierOrderStatusManagementEvent {
  const CashierOrderStatusManagementStarted();
}
