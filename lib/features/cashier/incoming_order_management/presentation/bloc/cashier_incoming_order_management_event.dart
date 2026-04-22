import 'package:equatable/equatable.dart';

abstract class CashierIncomingOrderManagementEvent extends Equatable {
  const CashierIncomingOrderManagementEvent();

  @override
  List<Object?> get props => [];
}

class CashierIncomingOrderManagementStarted extends CashierIncomingOrderManagementEvent {
  const CashierIncomingOrderManagementStarted();
}
