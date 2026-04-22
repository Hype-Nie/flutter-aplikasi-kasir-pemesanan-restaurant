import 'package:equatable/equatable.dart';

abstract class CashierAddonManagementEvent extends Equatable {
  const CashierAddonManagementEvent();

  @override
  List<Object?> get props => [];
}

class CashierAddonManagementStarted extends CashierAddonManagementEvent {
  const CashierAddonManagementStarted();
}
